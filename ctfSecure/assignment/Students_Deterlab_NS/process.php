<html>
<body>

<?php


$myFile = "/tmp/request.log";
$fh = fopen($myFile, 'a');

// TODO: use mysql transactions to avoid inconsistencies


// TODO: escape everything && move to $_POST
$user = $_GET["user"];
$pass = $_GET["pass"];
$choice = $_GET["drop"];
$amount = $_GET["amount"];


// TODO: Not use root account
$mysqli = new mysqli('localhost', 'root', 'rootmysql', 'ctf2');
if (!$mysqli) 
{
  // TODO: possible information disclosure
   die('Could not connect: ' . $mysqli->error());
}

// TODO: escape user and pass
$url="process.php?user=$user&pass=$pass&drop=balance";
$valid = null;
if ($choice == 'register')
{
  // TODO: prepared statement, instead
   $query = "insert into users (user,pass) values ('$user', '$pass')";
   $result = $mysqli->query($query);
   // TODO: possible XSS
   die('<script type="text/javascript">window.location.href="' . $url . '"; </script>');
} else {
  // TODO: validate username and password against db
  $valid = true;
}

if( valid == false ){

  // TODO: wrong userna/password combination
  die()

}

if ($choice == 'balance')
{
  // TODO: prepared statement, instead
   $query = "select * from transfers where user='$user'";
   $result = $mysqli->query($query);
   $sum = 0;

   // TODO: prevent XSS
   print "<H1>Balance and transfer history for $user</H1><P>";
   print "<table border=1><tr><th>Action</th><th>Amount</th></tr>";

   // TODO: safe fetch_array
   while ($row = $result->fetch_array())
   {
      // TODO: check if legit
      $amount = $row['amount'];
      if ($amount < 0)
      {
        $action = "Withdrawal";
       }
     else
      {
        $action = "Deposit";
      }

      // TODO: XSS
      print "<tr><td>" . $action . "</td><td>" . $amount . "</td></tr>";
      $sum += $amount;
    }

    // TODO: XSS, should not be possible since sum is a number but this is PHP
    print "<tr><td>Total</td><td>" . $sum . "</td></tr></table>";
    print "Back to <A HREF='index.php'>home</A>";		    
}
else if ($choice == 'deposit')
{
  // TODO: prepared statement
    // TODO: check amount before deposit
  $query = "insert into transfers (user,amount) values ('$user', '$amount')";
  $result = $mysqli->query($query);

  // TODO: XSS
  die('<script type="text/javascript">window.location.href="' . $url . '"; </script>');
}
else if($choice == 'withdraw')
{
  // TODO: prepared statement
  // TODO: check amount before withdraw
  $query = "insert into transfers (user,amount) values ('$user', -'$amount')";
  $result = $mysqli->query($query);

  // TODO: XSS
  die('<script type="text/javascript">window.location.href="' . $url . '"; </script>');
} else {

  die("Invalid choice");

}


//Log data for scoring
// TODO: this is NOT SQLi
// TODO: add timestamop to log
$query = "select * from transfers";
$result = $mysqli->query($query);
fwrite($fh, "BEGIN\n");
fwrite($fh, "TRANSFERS\n");
while ($row = $result->fetch_array())
{
    fwrite($fh, $row['user'] . " " . $row['amount'] . "\n");
}
$query = "select * from users";
$result = $mysqli->query($query);
fwrite($fh, "USERS\n");
while ($row = $result->fetch_array())
{
    fwrite($fh, $row['user'] . " " . $row['pass'] . "\n");
}
fwrite($fh, "END\n");
?>

</body>
</html>
