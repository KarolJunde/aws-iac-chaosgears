<?php
  $url = "http://169.254.169.254/latest/meta-data/";
  $instance_id = file_get_contents($url . "instance-id");
  $local_hostname = file_get_contents($url . "local-hostname");
  $local_ipv4 = file_get_contents($url . "local-ipv4");
  $public_hostname = file_get_contents($url . "public-hostname");
  $public_ipv4 = file_get_contents($url . "public-ipv4");
  echo "<b>instance-id:</b> " . $instance_id . "<br/>";
  echo "<b>local-hostname:</b> " . $local_hostname . "<br/>";
  echo "<b>local-ipv4:</b> " . $local_ipv4 . "<br/>";
  echo "<b>public-hostname:</b> " . $public_hostname . "<br/>";
  echo "<b>public-ipv4:</b> " . $public_ipv4 . "<br/>";
?>