<html><head><title>FrobozzCo Community Credit Union</title></head>
<body>
<h1>FrobozzCo Community Credit Union</h1>
<h4><i>We're working for GUE</i></h4>
<hr>
<?php

$debugmode = 0;
function debug($msg) {

        global $debugmode;

        if ($debugmode) {
                echo "<h4>$msg</h4>\n";
        }
}

$thispage = 'FCCU.php';
echo "<form action='$thispage' method='post' name='theform'>\n";
$dbuser = 'fccu';
$dbpass = 'fccubucks';
$dbhost = 'localhost';
$dbname = $dbuser;

$PARAM = array_merge($_GET, $_POST);

// get username and password from form
if (!$PARAM['id'] || !$PARAM['password']) {
        login();
} else { // otherwise, attempt to authenticate
        $id = $PARAM['id'];
        $password = $PARAM['password'];

        $mysqli = new mysqli($dbhost, $dbuser, $dbpass, $dbname);
        $query = "SELECT * FROM accounts WHERE id = $id AND password = '$password'";
        debug($query);
        $result = $mysqli->query($query) or die($mysqli->error());
        $row =  $result->fetch_array(); // there should be only one row

        if (!$row) { // auth failure
                echo "<p><b>Your ID number and password you entered do not match.</b></p>";
                echo "<p>Please try again.</p>";
                login();
        } else { // this user is authenticated!

                // store authentication information in this form
                echo "<input type=\"hidden\" name=\"id\" value=\"$id\" />\n";
                echo "<input type=\"hidden\" name=\"password\" value=\"$password\" />\n";

                banner($row[2], $row[3]);

                // perform any requested actions (wire, transfer, withdraw)
                if ($PARAM['action'] == 'Transfer Money') {
                        transfer_funds($id,
                                       $password,
                                       $PARAM['transfer_to'],
                                       $PARAM['transfer_amount']);
                } elseif ($PARAM['action'] == 'Wire Money') {
                        wire_funds($id,
                                    $password,
                                    $PARAM['routing'],
                                    $PARAM['wire_acct'],
                                    $PARAM['wire_amount']);
                } elseif ($PARAM['action'] == 'Withdraw Money') {
                        withdraw_cash($id,
                                      $password,
                                      $PARAM['withdraw_amount']);
                }

                // normal output

                // account info
                $query = "SELECT * FROM accounts WHERE id = $id AND password = '$password'";
                $result = $mysqli->query($query) or die($mysqli->error());
                 $row = $result->fetch_array(); // there should be only one row
                account_info($row);

                // get current account list by name
                $query = "SELECT first, last FROM accounts ORDER BY last";
                $names = $mysqli->query($query) or die($mysqli->error());
                account_actions($row, $names);
        }


}
echo "<hr>\n";
echo "Generated by FCCU.php at " . date("l M dS, Y, H:i:s",5678)."<br>";

function name_to_id($name) {

        global $dbhost, $dbuser, $dbpass, $dbname;
        $splitname = explode(", ", $name);

        $mysqli = new mysqli($dbhost, $dbuser, $dbpass, $dbname);
        $query = "SELECT id FROM accounts WHERE first = '$splitname[1]' AND last = '$splitname[0]'";

        $result = $mysqli->query($query) or die($mysqli->error());
        $row = $result->fetch_array();
        $id = $row[0];

        return $id;
}

function action_error($msg, $error) {

        echo "<table bgcolor='#ff0000' color='#ffffff' align=center border=1>
              <tr><td><center><b>ERROR!</b></center></td></tr>
              <tr><td>
                      <p align='center'>$msg</p>
                      <p align='center'>Please go back and try again or contact tech support.</p>
                      <p align='center'><i>args: $error</i></p>
                      <p align='center'><input type='submit' name='clear' value='Clear Message'></p>

                      </td></tr>
              </table>";
}

function withdraw_cash($id, $password, $amount) {

        global $dbhost, $dbuser, $dbpass, $dbname;

        $amount = floor($amount);

        $mysqli = new mysqli($dbhost, $dbuser, $dbpass, $dbname);

        $query = "SELECT bal FROM accounts WHERE password = '$password' AND id = $id";
        $result = $mysqli->query($query) or die ($mysqli->error());

        $row = $result->fetch_array();
        $giver_has = $row[0];

        if ($amount > 0 && $giver_has >= $amount) {
                $giver_has = $giver_has - $amount; // there's a problem here but it's not SQL Injection...
                pretend("withdraw cash", $amount);
                $query = "UPDATE accounts SET bal = $giver_has WHERE password = '$password' AND id = $id LIMIT 1";
                $mysqli->query($query) or die($mysqli->error());
                echo "<h2 align='center'>Cash withdrawal of $$amount complete.</h2>
                      <h3 align='center'>Your cash should be ready in accounting within 45 minutes.</h3>\n";
        } else {
                action_error("Problem with cash withdrawal!",
                             "'$id', '$giver_has', '$amount'");
        }
}


function wire_funds($id, $password,  $bank, $account, $amount) {

        global $dbhost, $dbuser, $dbpass, $dbname;

        $amount = floor($amount);

        $mysqli = new mysqli($dbhost, $dbuser, $dbpass, $dbname);

        $query = "SELECT bal FROM accounts WHERE password = '$password' AND id = $id";
        debug($query);
        $result = $mysqli->query($query) or die($mysqli->error());

        $row = $result->fetch_array();
        $giver_has = $row[0];

        if ($amount > 0 && $giver_has >= $amount && $bank && $account) {
                $giver_has = $giver_has - $amount; // there's a problem here but it's not SQL Injection...
                pretend("wire money", $amount, $bank, $acct);
                $query = "UPDATE accounts SET bal = $giver_has WHERE password = '$password' AND id = $id LIMIT 1";
                debug($query);
                $mysqli->query($query) or die($mysqli->error());
                echo "<h2 align='center'>Wire of $$amount to bank ($bank) account ($account) complete.</h2>\n";
        } else {
                action_error("Problem with wire fund transfer!",
                             "'$id', '$amount', '$giver_has', '$bank', '$account'");
        }
}

function pretend() {

        return 1;
}

function transfer_funds($giver_id, $password, $recipient, $amount) {

        global $dbhost, $dbuser, $dbpass, $dbname;

        $amount = floor($amount);
        $recipient_id = name_to_id($recipient);

        $mysqli = new mysqli($dbhost, $dbuser, $dbpass, $dbname);

        $query = "SELECT bal FROM accounts WHERE id = $giver_id";
        debug($query);
        $result = $mysqli->query($query) or die($mysqli->error());
        $row = $result->fetch_array();
        $giver_has = $row[0];


        $query = "SELECT bal FROM accounts WHERE id = $recipient_id";
        debug($query);
        $result = $mysqli->query($query) or die($mysqli->error());
        $row = $result->fetch_array();
        $recipient_has = $row[0];

        debug("$giver_has, $recipient_has");

        if ($amount > 0 && $giver_has >= $amount) {
                $giver_has = $giver_has - $amount; // there's a problem here but it's not SQL Injection...
                $recipient_has = $recipient_has + $amount;
                $query = "UPDATE accounts SET bal = $recipient_has WHERE id = $recipient_id LIMIT 1";
                debug($query);
                $mysqli->query($query) or die($mysqli->error());
                $query = "UPDATE accounts SET bal = $giver_has WHERE password = '$password' AND id = $giver_id LIMIT 1";
                debug($query);
                $mysqli->query($query) or die($mysqli->error()); // does anyone know what it is?
                echo "<h2 align='center'>Transfer of $$amount to $recipient complete.</h2>\n";
        } else {
                action_error("Problem with employee fund transfer!",
                             "'$giver_id', '$recipient', '$amount', '$giver_has'");
        }
}

function account_info($row) {

        echo "<table border='1' align='center'>
              <tr><td colspan='2'><p><center><b>Account Information</b></center></p></td></tr>
              <tr><td><b>Account:</b></td><td>$row[0]</td></tr>
              <tr><td><b>Balance:</b></td><td>$$row[1]</td></tr>
              <tr><td><b>Birthdate:</b></td><td>$row[6]</td></tr>
              <tr><td><b>SSN:</b></td><td>$row[5]</td></tr>
              <tr><td><b>Phone:</b></td><td>$row[4]</td></tr>
              <tr><td><b>Email:</b></td><td>$row[7]@frobozzco.com</td></tr>
              </table>\n";
}

function account_actions($row, $names) {

        global $thispage;

        echo "<table border=1 width='600' align='center'>

              <tr><td><center><b>Account Actions</b></center></td></tr>

              <tr><td><center><b>Wire Funds</b></center></td></tr>

              <tr><td>
              <p>To wire funds: enter the amount (in whole dollars), the
              receiving bank's <b>routing number</b> and <b>receiving account number</b>,
              and press 'Wire Funds!'</p>
              Wire amount: $<input name=wire_amount /><br />
              Routing Number: <input name=routing /> (e.g. 091000022)<br />
              Account Number: <input name=wire_acct /> (e.g. 923884509)<br />
              <p align='center'><input type='submit' name='action' value='Wire Money'></p>
              <p />
              </td></tr>

              <tr><td><center><b>Transfer Money</b></center></td><tr>

              <tr><td><p>To transfer money to another FCCU account holder, select the
              employee from the drop-down menu below, enter an ammount (in whole dollars)
              to transfer, and press 'Transfer Money!'</p>
              Transfer Amount: $<input name=transfer_amount /><br />
              Transfer To: ";
              // create dropdown menu with accounts
              echo "<select name='transfer_to' selected='select employee'>\n";
              echo "<option value='nobody'>select employee</option>\n";
              while ($name = $names->fetch_array()) {
                      echo "<option value=\"$name[1], $name[0]\">$name[1], $name[0]</option>\n";
              }
              echo "</select>\n";
              echo "<br />
              <p align='center'><input type='submit' name='action' value='Transfer Money'></p>
              <p />
              </td></tr>

              <tr><td><center><b>Withdraw Cash</b></center></td><tr>

              <tr><td><p>To withdraw cash, enter an amount (in whole dollars) and press
              the 'Withdraw Cash!' button. The cash will be available in the accounting
              office within 45 minutes.</p>
              Withdraw Amount: $<input name=withdraw_amount /><br />
              <p align='center'><input type='submit' name='action' value='Withdraw Money'></p>
              <p />
              </td></tr>
              </table>
              \n";

}

function banner($a, $b) {

        global $thispage;

        $fullname = "$a $b";
        echo "<table width='100%'><tr><td>
        <p align='left'>Welcome, $fullname. (<a href='$thispage'>Log Out</a>)</p>
              </td><td>
              <p align='right'><i>(If you aren't $fullname, <a href='$thispage'>click here</a>.)</i></p>
              </td></tr></table>\n";
        echo "<hr>\n";


}

function login() {

        global $thispage;

        echo "<p>Enter your <b>account ID</b> and password and click \"submit.\"</p>\n";
        echo "<table>\n";
        echo "<tr><td>Account ID Number: </td><td><input name='id' cols='10' /></td></tr>\n";
        echo "<tr><td>Password (alphanumeric only): </td><td><input name='password' cols='30' /></td></tr>\n";
        echo "<tr><td><input type='submit' value='Submit' name='submit'></td><td></td></tr>\n";
        echo "</table>\n";

}

?>
</form>
<p>Done.</p>
</body>
</html>