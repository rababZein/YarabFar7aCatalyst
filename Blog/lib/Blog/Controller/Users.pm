package Blog::Controller::Users;
use Moose;
use namespace::autoclean;
use Digest::MD5;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Blog::Controller::Users - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub base :Chained('/') :PathPart('users') :CaptureArgs(0) {
    my ($self, $c) = @_;
 
    # Store the ResultSet in stash so it's available for other methods
    $c->stash(resultset => $c->model('DB::User'));
 
    # Print a message to the debug log
    $c->log->debug('*** INSIDE BASE METHOD ***');
}

sub form_create :Chained('base') :PathPart('form_create') :Args(0) {
    my ($self, $c) = @_;
 
    # Set the TT template to use
    $c->stash(template => 'users/form_create.tt');
}



=head2 form_create_do
 
Take information from form and add to database
 
=cut
 
sub form_create_do :Chained('base') :PathPart('form_create_do') :Args(0) {
    my ($self, $c) = @_;
 
    # Retrieve the values from the form
    my $username     = $c->request->params->{username}     || 'N/A';
    my $email    = $c->request->params->{email}    || 'N/A';
    my $password = $c->request->params->{password} ;
    #$password  = Digest::MD5::md5_hex($password);
    # Create the book
    my $user = $c->model('DB::User')->create({
            username   => $username,
            email  => $email,
	    password  => $password,
        });
#password  => Digest::MD5::md5_hex($password),


    # Handle relationship with author
    #$book->add_to_book_authors({author_id => $author_id});
    # Note: Above is a shortcut for this:
    # $book->create_related('book_authors', {author_id => $author_id});
 
    # Store new model object in stash and set template
    $c->response->redirect($c->uri_for($self->action_for('list')));
}

sub list :Local {
	my ($self, $c) = @_;
	$c->stash(users => [$c->model('DB::User')->all]);
	$c->stash(template => 'users/list.tt');
}

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Blog::Controller::Users in Users.');
}

=head2 object
 
Fetch the specified book object based on the book ID and store
it in the stash
 
=cut
 
sub object :Chained('base') :PathPart('id') :CaptureArgs(1) {
    # $id = primary key of book to delete
    my ($self, $c, $id) = @_;
 
    # Find the book object and store it in the stash
    $c->stash(object => $c->stash->{resultset}->find($id));
 
    # Make sure the lookup was successful.  You would probably
    # want to do something like this in a real app:
    #   $c->detach('/error_404') if !$c->stash->{object};
    die "User $id not found!" if !$c->stash->{object};
 
    # Print a message to the debug log
    $c->log->debug("*** INSIDE OBJECT METHOD for obj id=$id ***");
}

=head2 delete
 
Delete a book
 
=cut
 
sub delete :Chained('object') :PathPart('delete') :Args(0) {
    my ($self, $c) = @_;
 
    # Use the book object saved by 'object' and delete it along
    # with related 'book_author' entries
    $c->stash->{object}->delete;
 
    # Set a status message to be displayed at the top of the view
    $c->stash->{status_msg} = "User deleted.";
 
    # Forward to the list action/method in this controller
    #$c->forward('list');
    # Redirect the user back to the list page.  Note the use
    # of $self->action_for as earlier in this section (BasicCRUD)
    $c->response->redirect($c->uri_for($self->action_for('list')));
}

sub form_update :Chained('object') :PathPart('form_update') :Args(0) {
    my ($self, $c) = @_;
 
    # Set the TT template to use
    $c->stash(user=>$c->stash->{object},template => 'users/form_update.tt');
}

sub update :Chained('object') :PathPart('update') :Args(0) {
    my ($self, $c) = @_;
    my $username     = $c->request->params->{username};
    my $email    = $c->request->params->{email};
    my $password = $c->request->params->{password} ;
    $c->stash->{object}->update({
	username   => $username,
        email  => $email,
	password  => Digest::MD5::md5_hex($password),
    });
    $c->response->redirect($c->uri_for($self->action_for('list')));
} 



=encoding utf8

=head1 AUTHOR

Rabab Zein,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
