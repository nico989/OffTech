<html>
<body>

<!-- Change to body -->
<form action="process.php" method="get">
Username: <input type="text" name="user">

<!-- Change type="password" -->
Password: <input type="text" name="pass">

<!-- Change to type="number" -->
Amount: <input type="text" name="amount">
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
