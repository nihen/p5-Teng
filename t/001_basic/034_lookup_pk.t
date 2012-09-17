use t::Utils;
use Mock::Basic;
use Test::More;

my $dbh = t::Utils->setup_dbh;
my $db_basic = Mock::Basic->new({dbh => $dbh});
$db_basic->setup_test_db;

subtest 'lookup_pk default' => sub {
    Mock::Basic->load_plugin('LookupPK');
    $db_basic->insert('mock_basic', => +{
        id   => 1,
        name => 'perl',
    });

    my $row = $db_basic->lookup_pk('mock_basic', 1);
    isa_ok $row, 'Mock::Basic::Row::MockBasic';
    is_deeply $row->get_columns, +{
        id        => 1,
        name      => 'perl',
        delete_fg => 0,
    };
    undef &Mock::Basic::lookup_pk;
};

subtest 'lookup_pk specify pk_name' => sub {
    Mock::Basic->load_plugin('LookupPK', {pk => 'name'});

    $db_basic->insert('mock_basic', => +{
        id   => 2,
        name => 'ruby',
    });

    my $row = $db_basic->lookup_pk('mock_basic', 'ruby');
    isa_ok $row, 'Mock::Basic::Row::MockBasic';
    is_deeply $row->get_columns, +{
        id        => 2,
        name      => 'ruby',
        delete_fg => 0,
    };

    undef &Mock::Basic::lookup_pk;
};

done_testing;

