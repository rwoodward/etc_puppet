require 'spec_helper'

describe 'database_schema::flyway' do
  let(:facts){{:operatingsystem => 'RedHat', :osfamily => 'RedHat'}}
  include_examples :compile
end