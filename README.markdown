actioncontroller-parameter_filter
=================================

Summary
-------

ParameterFilter is a module to mix into ActionController subclasses. It inserts
a before_filter which will automatically remove any fields in params that are
not explicitly allowed.

Installation
------------

Include the following in your Gemfile:

    gem "actioncontroller-parameter_filter"

Usage
-----

For global security, include the following in your ApplicationController:

    include ParameterFilter

Then, inside each of you controllers, specify what fields you want each action
to receive:

    # Accept user[email] and user[password] on the create and update actions.
    accepts :fields => { :user => [ :email, :password ] }, :on => [ :create, :update ]

    # Accept user[email] and user[password] on all actions.
    accepts fields: { user: %w( email password ) } 

    # Accept q on the search action.
    accepts field: "q", on: "search"

    # Accept q and sort on the search and index actions.
    accepts fields: [ :q, :sort ], on: %w( search index )

ParameterFilter should be pretty flexible in what you throw at it.

NOTE: All actions are automatically allowed to receive :controller, :action and
:id.
