define vyatta::service::webproxy (
  $ensure = present,
  $configuration = {},
  $webproxy = $name,
) {
  concat::fragment { "webproxy_${webproxy}":
    target  => "${vyatta::configuration_file}",
    content => template('vyatta/webproxy.erb'),
    order   => 403,
  }
}
