require 'helper'

class TestOptionParser < Test::Unit::TestCase
  include JRubySQLTestHelper

  def test_dbms_type
    # No host
    assert_error /Invalid connection/, parse(%w[-t mysql])
    assert_error /Invalid connection/, parse(%w[--type mysql])

    # No type
    assert_error /Invalid connection/, parse(%w[-h localhost])
    assert_error /Invalid connection/, parse(%w[--host localhost])

    # Invalid type
    assert_error /not supported/, parse(%w[-t yoursql -h localhost])

    # Optional options
    opts = parse(%w[-t MySQL -h localhost])
    assert_equal :mysql,      opts[:type]
    assert_equal 'localhost', opts[:host]

    opts = parse(%w[-t MySQL -h localhost -uroot])
    assert_equal :mysql,      opts[:type]
    assert_equal 'localhost', opts[:host]
    assert_equal 'root',      opts[:user]

    opts = parse(%w[-t MySQL -h localhost -uroot -dtest])
    assert_equal :mysql,      opts[:type]
    assert_equal 'localhost', opts[:host]
    assert_equal 'root',      opts[:user]
    assert_equal 'test',      opts[:database]

    [
      %w[-t mysql -h localhost -u username -p password -d database -o csv],
      %w[--type mysql --host localhost --user username --password password --database database --output csv]
    ].each do |argv|
      opts = parse(argv)
      assert_equal :mysql,      opts[:type]
      assert_equal 'localhost', opts[:host]
      assert_equal 'username',  opts[:user]
      assert_equal 'password',  opts[:password]
      assert_equal 'database',  opts[:database]
      assert_equal 'csv',       opts[:output]
    end
  end

  def test_class_name
    # No JDBC URL
    assert_error /Invalid connection/, parse(%w[-c com.mysql.jdbc.Driver])
    assert_error /Invalid connection/, parse(%w[--class-name com.mysql.jdbc.Driver])

    # No class name
    assert_error /Invalid connection/, parse(%w[-j jdbc:mysql://localhost/test])
    assert_error /Invalid connection/, parse(%w[--jdbc-url jdbc:mysql://localhost/test])

    [
      %w[-c com.mysql.jdbc.Driver -j jdbc:mysql://localhost -u username -p password -d database -o cterm],
      %w[--class-name com.mysql.jdbc.Driver --jdbc-url jdbc:mysql://localhost
         --user username --password password --database database --output cterm]
    ].each do |argv|
      opts = parse(argv)
      assert_equal 'com.mysql.jdbc.Driver',  opts[:driver]
      assert_equal 'jdbc:mysql://localhost', opts[:url]
      assert_equal 'username',               opts[:user]
      assert_equal 'password',               opts[:password]
      assert_equal 'database',               opts[:database]
      assert_equal 'cterm',                  opts[:output]
    end
  end

  def test_invalid_output
    assert_error /Invalid output/, parse(%w[-t mysql -h localhost -o xml])
  end

  def test_invalid_combination
    assert_error /Invalid connection/, parse(%w[-t mysql -j jdbc:mysql://localhost])
    assert_error /Invalid connection/, parse(%w[-c com.mysql.jdbc.Driver -h localhost])

    assert_error /both filename and script/, parse(%w[-f aaa -e bbb])
  end

  def test_filename
    assert_error /File not found/, parse(%w[-t mysql -h localhost -f no-such-file.sql])

    opts = parse(%w[-t mysql -h localhost -f] + [__FILE__])
    assert_equal __FILE__, opts[:filename]

    opts = parse(%w[-t mysql -h localhost --filename] + [__FILE__])
    assert_equal __FILE__, opts[:filename]
  end

  def test_script
    opts = parse(%w[-t mysql -h localhost -e commit])
    assert_equal 'commit', opts[:script]

    opts = parse(%w[-t mysql -h localhost --execute commit])
    assert_equal 'commit', opts[:script]
  end

  def test_password_input
    # FIXME: ask_password is a private method. any better way?
    JRubySQL::OptionParser.expects(:ask_password).returns('password')
    opts = parse(%w[-t mysql -h localhost -p])
    assert_equal 'password', opts[:password]
  end

  def parse argv
    parse_with_output(argv)[:return]
  end

  def parse_with_output argv
    capture { JRubySQL::OptionParser.parse(argv) }
  end

  def assert_error msg, argv
    ret = parse_with_output argv
    assert_equal 1, ret[:return]
    assert msg, ret[:stdout] =~ msg
  end
end

