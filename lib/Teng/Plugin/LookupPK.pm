package Teng::Plugin::LookupPK;
use strict;
use warnings;
use utf8;

sub init {
    my ( $class, $teng, $opt ) = @_;

    my $pk_name = defined $opt && exists $opt->{pk} ? $opt->{pk} : 'id';
    
    no strict 'refs';
    *{$teng . '::lookup_pk'} = sub {
        my ($self, $table_name, $pk, $opt) = @_;

        my $table = $self->{schema}->get_table( $table_name );
        Carp::croak("No such table $table_name") unless $table;

        my $sql = sprintf('SELECT * FROM %s WHERE %s = ? LIMIT 1 %s',
           $table_name,
           $pk_name,
           $opt->{for_update} ? 'FOR UPDATE' : '',
        );

        my $sth = $self->_execute($sql, [$pk]);
        my $row = $sth->fetchrow_hashref($self->{fields_case});

        return unless $row;
        return $row if $self->{suppress_row_objects};

        $table->{row_class}->new(
            {
                sql        => $sql,
                row_data   => $row,
                teng       => $self,
                table      => $table,
                table_name => $table_name,
            }
        );
    };
}


1;
__END__

=head1 NAME

Teng::Plugin::LookupPK - lookup by single primary key.

=head1 NAME

    package MyDB;
    use parent qw/Teng/;
    __PACKAGE__->load_plugin('LookupPK');
    # same as 
    # __PACKAGE__->load_plugin('LookupPK', { pk => 'id' });

    package main;
    my $db = MyDB->new(...);
    $db->lookup_pk('user' => 1); # => get single row

=head1 DESCRIPTION

This plugin provides fast lookup row .

=head1 METHODS

=over 4

=item $row = $db->lookup_pk($table_name, $pk, [\%attr]);

lookup single row records.

Teng#single is heavy.

=back

