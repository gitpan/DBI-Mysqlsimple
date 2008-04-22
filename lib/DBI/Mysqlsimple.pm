package DBI::Mysqlsimple;

use warnings;
use strict;
use Carp qw/croak/;
use DBI;

use vars qw/$VERSION/;
$VERSION = '0.01';

sub new
{
    my ($caller,$db,$host,$user,$passwd) = @_;
    my $class = ref $caller || $caller;

    $db ||= 'test';
    $host ||= '127.0.0.1';
    $user ||= 'root';
    $passwd ||= '';

    my $dbh = DBI->connect("dbi:mysql:$db:$host", $user, $passwd)
                           or croak $DBI::errstr;

    bless { 'dbh'=>$dbh }, $class;
}


sub get_rows
{
    my ($self,$str,$ref) = @_;

    my @values;
    @values = @$ref if defined $ref;

    my $dbh = $self->{'dbh'};
    my $sth = $dbh->prepare($str);

    $sth->execute(@values) or croak $dbh->errstr;
    
    my @records;
    while ( my $ref = $sth->fetchrow_hashref ) {
        push @records, $ref;
    }

    $sth->finish;

    return \@records;
}


sub get_row
{
    my ($self,$str,$ref) = @_;

    my @values;
    @values  = @$ref if defined $ref;

    my $dbh = $self->{'dbh'};
    my $sth = $dbh->prepare($str);

    $sth->execute(@values) or croak $dbh->errstr;

    my @records = $sth->fetchrow_array;
    $sth->finish;

    return @records;
}


sub set_db
{
    my ($self,$str,$ref) = @_;

    my @values;
    @values = @$ref if defined $ref;

    my $dbh = $self->{'dbh'};
    my $sth = $dbh->prepare($str);

    $sth->execute(@values) or croak $dbh->errstr;
    $sth->finish;
}
    

sub disconnect
{
    my ($self) = @_;

    my $dbh = $self->{'dbh'};
    $dbh->disconnect;
}


#
#self destroy
#
sub DESTROY 
{
    my $self = shift;
    my $dbh = $self->{'dbh'};
    if ($dbh) {
        local $SIG{'__WARN__'} = sub {};
        $dbh->disconnect();
    }
}


1;



=head1 NAME

DBI::Mysqlsimple - A simple Mysql database interface using DBI

=head1 VERSION

Version 0.01

=cut


=head1 SYNOPSIS

    use DBI::Mysqlsimple;
    my $db = DBI::Mysqlsimple->new($db,$host,$user,$passwd);

    my ($v1,$v2) = $db->get_row("select v1,v2 from table");
    my ($v1,$v2) = $db->get_row("select v1,v2 from table where 
                       cond1=? and cond2=?", [$cond1,$cond2]);
    
    my $rows = $db->get_rows("select * from table where cond=?",
                             [$cond]);
    for my $r (@$rows) {
        print $r->{column1}, $r->{column2}, "\n";
    }

    $db->set_db("delete from table where cond=?", [$cond]);
    $db->set_db("update table set c1=?,c2=? where cond=?",
                [$c1,$c2,$cond]);

    $db->disconnect;


=head1 METHODS

=head2 new(db,host,user,passwd)

Create a new object. The four arguments are generally needed:

    db: database name
    host: mysql host
    user: mysql user
    passwd: mysql password


=head2 get_row(sql, [[cond1,cond2]])

Fetch a single row of record. The results are returned as a list.

For example, you can do:

    my ($v1,$v2) = $db->get_row("select v1,v2 from table");

The selected values are assigned to $v1 and $v2 directly.

If you need to pass query arguments with a sql to the method,
you'd better do:

    my ($v1,$v2) = $db->get_row("select v1,v2 from table where
                       cond1=? and cond2=?", [$cond1,$cond2]);

Also the query results are returned as a list.


=head2 get_rows(sql, [[cond1,cond2]])

Fetch multi-rows of records. The results are returned as an array 
reference.

For example, you can say:

    my $rows = $db->get_rows("select column1,column2 from table where 
                              cond=?", [$cond]);
    for my $r (@$rows) {
        print $r->{column1}, $r->{column2}, "\n";
    }

Here $rows is an array reference. The array's each element is a hash
reference, whose keys are the table's columns name. This method is the
same as DBI's fetchrow_hashref().

Note: If you have large datas needed to be returned, don't use this 
method. It will consume the memory. You should use DBI's standard
fetchrow_hashref() or fetchrow_arrayref() ways.


=head2 set_db(sql, [[cond1,cond2]])

Update the database, including update/delete etc.

For example, the statement below:

    $db->set_db("update table set c1=?,c2=? where cond=?",
                [$c1,$c2,$cond]);

will update the table with specified values ($c1,$c2) follow the special 
condition ($cond).


=head2 disconnect()

Disconnect from the database.


=head1 AUTHOR

Jeff Pang <pangj@earthlink.net>


=head1 BUGS/LIMITATIONS

Before using this module, you must have DBI and DBD::mysql installed 
correctly in your system.

If you have found bugs, please send mail to <pangj@earthlink.net>


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc DBI::Mysqlsimple

You may see also:

    perldoc DBI


=head1 COPYRIGHT & LICENSE

Copyright 2008 Jeff Pang, all rights reserved.

This program is free software; you can redistribute it and/or modify 
it under the same terms as Perl itself.

=cut
