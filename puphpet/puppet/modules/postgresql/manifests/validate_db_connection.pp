# This type validates that a successful postgres connection can be established
# between the node on which this resource is run and a specified postgres
# instance (host/port/user/password/database name).
#
# See README.md for more details.
define postgresql::validate_db_connection(
  $database_host     = undef,
  $database_name     = undef,
  $database_password = undef,
  $database_username = undef,
  $database_port     = undef,
  $connect_settings  = undef,
  $run_as            = undef,
  $sleep             = 2,
  $tries             = 10,
  $create_db_first   = true
) {
  include postgresql::client
  include postgresql::params

  $psql_path = $postgresql::params::psql_path
  $validcon_script_path = $postgresql::client::validcon_script_path

  $cmd_init = "${psql_path} --tuples-only --quiet "
  $cmd_host = $database_host ? {
    undef   => '',
    default => "-h ${database_host} ",
  }
  $cmd_user = $database_username ? {
    undef   => '',
    default => "-U ${database_username} ",
  }
  $cmd_port = $database_port ? {
    undef   => '',
    default => "-p ${database_port} ",
  }
  $cmd_dbname = $database_name ? {
    undef   => "--dbname ${postgresql::params::default_database} ",
    default => "--dbname ${database_name} ",
  }
  $pass_env = $database_password ? {
    undef   => undef,
    default => "PGPASSWORD=${database_password}",
  }
  $cmd = join([$cmd_init, $cmd_host, $cmd_user, $cmd_port, $cmd_dbname], ' ')
  $validate_cmd = "${validcon_script_path} ${sleep} ${tries} '${cmd}'"

  # This is more of a safety valve, we add a little extra to compensate for the
  # time it takes to run each psql command.
  $timeout = (($sleep + 2) * $tries)

  # Combine $database_password and $connect_settings into an array of environment
  # variables, ensure $database_password is last, allowing it to override a password
  # from the $connect_settings hash
  if $connect_settings != undef {
    if $pass_env != undef {
      $env = concat(join_keys_to_values( $connect_settings, '='), $pass_env)
    } else {
      $env = join_keys_to_values( $connect_settings, '=')
    }
  } else {
    $env = $pass_env
  }

  $exec_name = "validate postgres connection for ${database_username}@${database_host}:${database_port}/${database_name}"

  exec { $exec_name:
    command     => "echo 'Unable to connect to defined database using: ${cmd}' && false",
    unless      => $validate_cmd,
    cwd         => '/tmp',
    environment => $env,
    logoutput   => 'on_failure',
    user        => $run_as,
    path        => '/bin:/usr/bin:/usr/local/bin',
    timeout     => $timeout,
    require     => Class['postgresql::client'],
  }

  # This is a little bit of puppet magic.  What we want to do here is make
  # sure that if the validation and the database instance creation are being
  # applied on the same machine, then the database resource is applied *before*
  # the validation resource.  Otherwise, the validation is guaranteed to fail
  # on the first run.
  #
  # We accomplish this by using Puppet's resource collection syntax to search
  # for the Database resource in our current catalog; if it exists, the
  # appropriate relationship is created here.
  if($create_db_first) {
    Postgresql::Server::Database<|title == $database_name|> -> Exec[$exec_name]
  }
}
