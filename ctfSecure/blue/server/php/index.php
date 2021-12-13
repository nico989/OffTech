<html>
<body>
<form action="process.php" method="get">
Username: <input type="text" name="user">
Password: <input type="password" name="pass">
Amount: <input type="number" name="amount">
Action: <select name='drop'>
  <option value='balance'>Balance and transfer history</option>
  <option value='register'>Register</option>
  <option value='deposit'>Deposit</option>
  <option value='withdraw'>Withdraw</option>
</select>
<input type="submit">
</form>

</body>
</html>
