<html>
<body>

<?php
  ### Header log ###
  $myFile = "/tmp/request.log";
  $fh = fopen($myFile, 'a');
  $timestamp = new DateTime("now", new DateTimeZone("Europe/Rome"));
  $dt = $timestamp->format("Y-m-d H:i:s");
  ### End header log ###

  ### Get and check query parameters ###
  if(isset($_GET["user"])){
    $user = htmlentities($_GET["user"], ENT_QUOTES);
  } else {
    $user = "";
  }

  if (strlen($user) === 0 || strlen($user) > 20) {
    errorClose(null, $fh, "Wrong query parameter.");
  }

  if(isset($_GET["pass"])){
    $pass = htmlentities($_GET["pass"], ENT_QUOTES);
  } else {
    $pass = "";
  }

  if (strlen($pass) === 0 || strlen($pass) > 32) {
    errorClose(null, $fh, "Wrong query parameter.");
  }

  if(isset($_GET["drop"])){
    $choice = htmlentities($_GET["drop"], ENT_QUOTES);
  } else {
    $choice = "";
  }

  if (strlen($choice) === 0 || strlen($choice) > 9) {
    errorClose(null, $fh, "Wrong query parameter.");
  }

  if(isset($_GET["amount"]) && preg_match("/^[0-9]{1,9}$/", $_GET["amount"])){
    $amount = intval($_GET["amount"]);
  } else {
    $amount = 0;
  }
  ### End get and check query parameters ###

  ### DB connection ###
  $mysqli = new mysqli("localhost", "offtech", "UnRsqUlTE3lufZR09gw2", "ourdb");
  if (!$mysqli) {
    errorClose(null, $fh, "Could not connect to database!");
  }
  ### End DB connection ### 

  ### Switch possibilities: register,balance,deposit,withdraw ###
  $url="process.php?user=$user&pass=$pass&drop=balance";
  switch ($choice) {
    case "register":
      if (checkUser($mysqli, $user)) {
        $query = $mysqli->prepare("INSERT INTO users_secure_table (username,password) VALUES (?,?);");
        $hashPass = hash("sha512", $pass);
        $query->bind_param("ss", $user, $hashPass);
        $query->execute() or errorClose($mysqli, $fh, "Something went wrong. </body></html>");
        $result = $query->get_result();

        errorClose($mysqli, $fh, null);
        die('<script type="text/javascript">window.location.href="' . $url . '"; </script>');
      } else {
        errorClose($mysqli, $fh, "User already exists.");
      }
      break;
    case "balance":
      if(checkCredentials($mysqli, $user, $pass)) {
        $query = $mysqli->prepare("SELECT * FROM transfers_secure_table_random WHERE username=? ORDER BY timestamp DESC LIMIT 100;");
        $query->bind_param("s", $user);
        $query->execute() or errorClose($mysqli, $fh, "Something went wrong. </body></html>");
        $result = $query->get_result();
        $sum = getTotalBalance($mysqli, $user);
        print "<h1>Balance and transfer history for $user</h1><p>";
        print "<table border=1><tr><th>Action</th><th>Amount</th></tr>";
        while ($row = $result->fetch_array())
        {
          $amount = $row["amount"];
          if ($amount < 0)
          {
            $action = "Withdrawal";
          }
        else
          {
            $action = "Deposit";
          }
          print "<tr><td>" . $action . "</td><td>" . $amount . "</td></tr>";
        }
        print "<tr><td>Total</td><td>" . $sum . "</td></tr></table>";
        print "Back to <a href='index.php'>home</a>";
      } else {
        errorClose($mysqli, $fh, "Authentication failed.");
      }
      break;
    case "deposit":
      if(checkCredentials($mysqli, $user, $pass)) {
        if (gettype($amount) != "integer" || $amount === 0 || $amount < 0 || $amount > 2147483647) {
          errorClose($mysqli, $fh, "Wrong amount.");
        } else { 
          $query = $mysqli->prepare("INSERT INTO transfers_secure_table_random (username,amount,timestamp) VALUES (?,?,?);");
          $query->bind_param("sis", $user, $amount, $dt);
          $query->execute() or errorClose($mysqli, $fh, "Something went wrong. </body></html>");
          $result = $query->get_result();

          errorClose($mysqli, $fh, null);
          die('<script type="text/javascript">window.location.href="' . $url . '"; </script>');
        }
      } else {
        errorClose($mysqli, $fh, "Authentication failed.");
      }
      break;
    case "withdraw":
      if(checkCredentials($mysqli, $user, $pass)) {
        if (gettype($amount) != "integer" || $amount === 0 || $amount < 0 || $amount > 2147483647) {
          errorClose($mysqli, $fh, "Wrong amount.");
        } else {
          $sum = getTotalBalance($mysqli, $user);
          if ($sum === 0 || $sum < $amount )  {
            errorClose($mysqli, $fh, "You can't withdraw.");
          } else {
            $amount = $amount * -1;
            $query = $mysqli->prepare("INSERT INTO transfers_secure_table_random (username,amount,timestamp) VALUES (?,?,?);");
            $query->bind_param("sis", $user, $amount, $dt);
            $query->execute() or errorClose($mysqli, $fh, "Something went wrong. </body></html>");
            $result = $mysqli->query($query);

            errorClose($mysqli, $fh, null);
            die('<script type="text/javascript">window.location.href="' . $url . '"; </script>');
          }
        }
      } else {
        errorClose($mysqli, $fh, "Authentication failed.");
      }
      break;
    default:
      errorClose($mysqli, $fh, "Invalid choice.");
      break;
  }
  ### End switch ###

  ### LOG DATA FOR SCORING ###
  $query = "SELECT * FROM transfers_secure_table_random;";
  $result = $mysqli->query($query);
  fwrite($fh, "BEGIN\n");
  fwrite($fh, "TRANSFERS\n");
  while ($row = $result->fetch_array())
  {
    fwrite($fh, $row["username"] . " " . $row["amount"] . " " . $row["timestamp"] . "\n");
  }
  $query = "SELECT * FROM users_secure_table;";
  $result = $mysqli->query($query);
  fwrite($fh, "USERS\n");
  while ($row = $result->fetch_array())
  {
      fwrite($fh, $row["username"] . " " . $row["password"] . "\n");
  }
  fwrite($fh, "END\n");
  fwrite($fh, "\n\n----\n\n");
  errorClose($mysqli, $fh, null);
  ### End log data for scoring ###

  ### Functions ###
  function checkUser($mysqli, $user) {
    $query = $mysqli->prepare("SELECT username FROM users_secure_table WHERE username=?;");
    $query->bind_param("s", $user);
    $query->execute() or errorClose($mysqli, $GLOBALS['fh'], "Something went wrong. </body></html>");
    $result = $query->get_result();
    $row = $result->fetch_array();
    if ($row == null) {
      return true;
    } else {
      return false;
    }
  }

  function checkCredentials($mysqli, $user, $pass) {
    $hashPass = hash("sha512", $pass);
    $query = $mysqli->prepare("SELECT username,password FROM users_secure_table WHERE username=? AND password=?;");
    $query->bind_param("ss", $user, $hashPass);
    $query->execute() or errorClose($mysqli, $GLOBALS['fh'], "Something went wrong. </body></html>");
    $result = $query->get_result();
    $row = $result->fetch_array();
    if($user === $row["username"] && $hashPass === $row["password"]) {
      return true;
    } else {
      return false;
    }
  }

  function getTotalBalance($mysqli, $user) {
    $query = $mysqli->prepare("SELECT SUM(amount) AS balance FROM transfers_secure_table_random WHERE username=?;");
    $query->bind_param("s", $user);
    $query->execute() or errorClose($mysqli, $GLOBALS['fh'], "Something went wrong. </body></html>");
    $result = $query->get_result();
    $row = $result->fetch_array();
    $balance = $row['balance'];
    if (is_null($balance)) {
      return 0;
    } elseif ($balance < 0) {
      errorClose($mysqli, $GLOBALS['fh'], "You reach the limit. Open another account.");
    } else {
      return $balance;
    }
  }

  function errorClose($mysqli, $fh, $message) {
    if (!is_null($mysqli)) {
      $mysqli->close();
    }
    if (!is_null($fh)) {
      fclose($fh);
    }
    if (!is_null($message)) {
      die("$message </body></html>");
    }
  }
  ### End functions ###

?>

</body>
</html>
