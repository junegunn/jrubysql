require 'helper'

# Acceptance test
class TestJRubySQL < Test::Unit::TestCase
  include JRubySQLTestHelper

  def test_help
    queue "
      help
      exit
    "
    ret = capture { launch }
    assert_equal 0, ret[:return]
    assert_match /Display this message/, ret[:stdout]
    assert_match /Goodbye!/, ret[:stdout]

    assert_prev_conn
  end

  def test_delimiter
    queue "
      select 1 from dual where 1 = 0;
      delimiter //
      select 1 -- //
        from /* // */ dual
        where 1 = 0 //
      //
      //
      //
      delimiter ;
      select 1 from dual where 1 = 0;
      exit
    "
    ret = capture { launch }

    assert_equal 3, ret[:stdout].scan(/0 row/).length
    assert_match /Goodbye!/, ret[:stdout]

    assert_prev_conn
  end

  def test_autocommit
    queue "
      drop table if exists jrubysql;
      create table if not exists jrubysql (a int) engine=innodb;
      autocommit

      insert 
        into /* ;;; */
      jrubysql
        values (1);

      autocommit off

      insert into -- ;;;
      jrubysql values (2);

      insert into jrubysql values (3);
      select count(*) from jrubysql;
      rollback;
      select count(*) from jrubysql;
      autocommit
      autocommit on
      autocommit
      drop table jrubysql;
      exit
    "
    # ANSI codes make it difficult to test
    ret = capture { launch [ '-o', 'term' ] }

    assert_equal %w[0 0 1 1 1 0 0], ret[:stdout].scan(/([0-9]+) rows? affected/).map(&:first)
    assert_equal %w[on off on], ret[:stdout].scan(/Current autocommit: (on|off)/).map(&:first)
    assert_equal %w[off on], ret[:stdout].scan(/Turning autocommit (on|off)/).map(&:first)
    assert_equal %w[3 1], ret[:stdout].scan(/^\| ([0-9]+)/).map(&:first)

    assert_prev_conn /-o term/
  end

  def test_now
    queue "
      now
      now
      now
      exit
    "
    ret = capture { launch }
    ymd = %r|#{Time.now.strftime('%Y/%m/%d %H')}:[0-9]{2}:[0-9]{2}.[0-9]{3}|
    assert_equal 3, ret[:stdout].scan(ymd).count

    assert_prev_conn
  end

  def test_csv
    queue "
      drop table if exists jrubysql;
      create table if not exists jrubysql (a int, b varchar(100), c varchar(100), d varchar(100));
      insert into jrubysql values (100, 'abc', 'def', 'ghi');
      insert into jrubysql values (200, 'x,y,z', null, '');
      select * from jrubysql order by a;
      drop table jrubysql;
      drop table jrubysql;
      exit
    "
    ret = capture { launch [ '-ocsv' ] }

    assert_equal [
      'a,b,c,d',
      '100,abc,def,ghi',
      '200,"x,y,z",,""' ], ret[:stdout].lines.map(&:chomp)
    # CSV prints error messages to STDERR
    assert_match /Unknown table/, ret[:stderr]

    assert_prev_conn /-ocsv/
  end

  def test_plural
    queue "
      drop table if exists jrubysql;
      create table if not exists jrubysql (a int);
      update jrubysql set a = 0;
      insert into jrubysql values (1);
      update jrubysql set a = 2;
      insert into jrubysql values (3);
      update jrubysql set a = 4;
      drop table jrubysql;
      exit;
    "
    ret = capture { launch }

    assert_equal [
      '0 row',
      '0 row',
      '0 row',
      '1 row',
      '1 row',
      '1 row',
      '2 rows',
      '0 row'
    ], ret[:stdout].scan(/([0-9]+ rows?) affected/).map(&:first)

    assert_prev_conn
  end

  def test_file
    require 'tempfile'
    tf = Tempfile.new('jrubysql')
    tf << "select 1 from dual where 1 = 0"
    tf.flush

    ret = capture { launch ['-f', tf.path] }
    assert_equal 1, ret[:stdout].scan(/0 row/).count

    assert_prev_conn /-f/
  end

  def test_script
    ret = capture { launch ['-e', "select 1 from dual where 1 = 0; select 1 from dual where 1 = 0"] }
    assert_equal 2, ret[:stdout].scan(/0 row/).count

    assert_prev_conn /-e/
  end

  def test_using_connection_history
    queue "
      drop table if exists jrubysql;
      create table if not exists jrubysql (a int);
      insert into jrubysql values (999);
      exit
    "
    capture { launch ['-ocsv'] }

    # FIXME: private static method
    JRubySQL::Controller.expects(:get_console_input).returns('1')
    queue "
      select * from jrubysql;
      drop table jrubysql;
      exit
    "
    ret = capture { JRubySQL.launch [] } 
    assert_equal '999', ret[:stdout].lines.map(&:chomp)[-1]

    assert_prev_conn /csv/
  end

  def test_interrupt
    pend do
      assert false, 'Need to test interrupt signal handling'
    end
  end

private
  def assert_prev_conn command = nil
    prev_conn = JRubySQL::Config.new['connections'].first
    # assert_equal :sqlite,   prev_conn.last[:type]
    # assert_match 'test.db', prev_conn.last[:host]
    assert_equal :mysql,      prev_conn.last[:type]
    assert_match 'localhost', prev_conn.last[:host]

    if command
      assert_match command,     prev_conn.first
    end
  end

  def queue str
    lines = str.strip.lines.map { |s| s.strip }
    Readline.expects(:readline).times(lines.length).returns(*lines)
  end

  def launch argv = []
    # db = File.join( File.dirname(__FILE__), 'test.db' )
    # JRubySQL.launch ['-tsqlite', '-h', db ] + argv
    JRubySQL.launch %w[-tmysql -hlocalhost -dtest] + argv
  end
end
