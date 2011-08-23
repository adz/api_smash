require 'spec_helper'

describe ApiSmash do

  let(:my_api_smash) { Class.new(ApiSmash) }

  describe 'transformers' do

    it 'should let you define a transformer via transformer_for' do
      my_api_smash.property :name
      my_api_smash.transformers['name'].should be_nil
      my_api_smash.transformer_for :name, lambda { |v| v.to_s.upcase }
      my_api_smash.transformers['name'].should_not be_nil
      my_api_smash.transformers['name'].call('a').should == 'A'
    end

    it 'should let you pass a block to transformer_for' do
      my_api_smash.property :name
      my_api_smash.transformers['name'].should be_nil
      my_api_smash.transformer_for(:name) { |v| v.to_s.upcase }
      my_api_smash.transformers['name'].should_not be_nil
      my_api_smash.transformers['name'].call('a').should == 'A'
    end

    it 'should accept a symbol for transformer' do
      my_api_smash.property :name
      my_api_smash.transformers['name'].should be_nil
      my_api_smash.transformer_for :name, :to_i
      my_api_smash.transformers['name'].should_not be_nil
      my_api_smash.transformers['name'].call('1').should == 1
    end

    it 'should let you define a transformer via the :transformer property option' do
      my_api_smash.transformers['name'].should be_nil
      my_api_smash.property :name, :transformer => lambda { |v| v.to_s.upcase }
      my_api_smash.transformers['name'].should_not be_nil
      my_api_smash.transformers['name'].call('a').should == 'A'
    end

    it 'should automatically transform the incoming value' do
      my_api_smash.property :count, :transformer => lambda { |v| v.to_i }
      instance = my_api_smash.new
      instance.count = '1'
      instance.count.should == 1
    end

  end

  describe 'key transformations' do

    it 'should let you specify it via from' do
      my_api_smash.property :name, :from => :fullName
      my_api_smash.key_mapping['fullName'].should == 'name'
      my_api_smash.new(:fullName => 'Bob').name.should == 'Bob'
    end

    it 'should alias it for reading' do
      my_api_smash.property :name, :from => :fullName
      my_api_smash.new(:name => 'Bob')[:fullName].should == 'Bob'
    end

    it 'should alias it for writing' do
      my_api_smash.property :name, :from => :fullName
      instance = my_api_smash.new
      instance[:fullName] = 'Bob'
      instance.name.should == 'Bob'
    end

  end

  describe 'inheritance' do

    let(:parent_api_smash) { Class.new(ApiSmash) }
    let(:client_api_smash) { Class.new(parent_api_smash) }

    it 'should not overwrite parent class transformers' do
      parent_api_smash.transformers['a'].should be_nil
      client_api_smash.transformers['a'].should be_nil
      client_api_smash.transformer_for :a, :to_s
      parent_api_smash.transformers['a'].should be_nil
      client_api_smash.transformers['a'].should_not be_nil
    end

    it 'should not overwrite parent class key mapping' do
      parent_api_smash.key_mapping['b'].should be_nil
      client_api_smash.key_mapping['b'].should be_nil
      client_api_smash.property :a, :from => :b
      parent_api_smash.key_mapping['b'].should be_nil
      client_api_smash.key_mapping['b'].should_not be_nil
    end

    it 'should not overwrite the parent classes unknown key error' do
      parent_api_smash.exception_on_unknown_key?.should be_false
      client_api_smash.exception_on_unknown_key?.should be_false
      client_api_smash.exception_on_unknown_key = true
      parent_api_smash.exception_on_unknown_key?.should be_false
      client_api_smash.exception_on_unknown_key?.should be_true
    end

  end

  describe 'overriding the default key transformations' do

    it 'should let you override the default transformation method' do
      my_api_smash.property :name
      my_api_smash.class_eval do
        def default_key_transformation(key)
          key.to_s.downcase.gsub(/\d/, '')
        end
      end
      api_smash = my_api_smash.new
      api_smash[:NAME1] = 'Bob Smith'
      api_smash.name.should == 'Bob Smith'
    end

    it 'should default to transforming via to_s' do
      api_smash = my_api_smash.new
      api_smash.send(:default_key_transformation, :another).should == 'another'
    end

  end

  describe 'extending Hashie::Dash' do

    it 'should let you swallow errors on unknown keys' do
      my_api_smash.properties.should_not include(:name)
      my_api_smash.exception_on_unknown_key?.should be_false
      expect do
        my_api_smash.new(:name => 'Test')
      end.should_not raise_error
      my_api_smash.exception_on_unknown_key?.should be_false
    end

    it 'should raise an exception correctly when not ignoring unknown keys' do
      my_api_smash.properties.should_not include(:name)
      my_api_smash.exception_on_unknown_key = true
      my_api_smash.exception_on_unknown_key?.should be_true
      expect do
        my_api_smash.new[:name] = 'Test'
      end.to raise_error(NoMethodError)
      expect do
        my_api_smash.new[:name]
      end.to raise_error(NoMethodError)
      my_api_smash.exception_on_unknown_key?.should be_true
    end

    it 'should default to ignoring unknown key errors' do
      klass = Class.new(ApiSmash)
      klass.exception_on_unknown_key?.should be_false
      expect do
        klass.new[:my_imaginary_key] = 'of doom'
        klass.new[:my_imaginary_key]
      end.to_not raise_error(NoMethodError)
    end

    it 'should include aliases in :from when checking if properties are valid' do
      my_api_smash.should_not be_property(:name)
      my_api_smash.should_not be_property(:fullName)
      my_api_smash.property :name, :from => :fullName
      my_api_smash.should be_property(:name)
      my_api_smash.should be_property(:fullName)
    end

  end

  describe 'being a callable object' do

    before :each do
      my_api_smash.property :name
      my_api_smash.property :age, :transformer => :to_i
    end

    it 'should respond to call' do
      my_api_smash.should respond_to(:call)
    end

    it 'should correctly transform a hash' do
      instance = my_api_smash.call(:name => 'Bob', :age => '18')
      instance.should be_a(my_api_smash)
      instance.name.should == 'Bob'
      instance.age.should == 18
    end

    it 'should correctly transform an array' do
      instance = my_api_smash.call([{:name => 'Bob', :age => '18'}, {:name => 'Rick', :age => '19'}])
      instance.should be_a(Array)
      instance.first.should be_a(my_api_smash)
      instance.first.name.should == 'Bob'
      instance.first.age.should == 18
      instance.last.should be_a(my_api_smash)
      instance.last.name.should == 'Rick'
      instance.last.age.should == 19
    end

    it 'should return nil for unknown types' do
      my_api_smash.call(100).should be_nil
      my_api_smash.call(nil).should be_nil
      my_api_smash.call("Oh look, a pony!").should be_nil
    end

    it 'should return itself when passed in' do
      instance = my_api_smash.new(:name => "Bob", :age => 18)
      transformed = my_api_smash.call(instance)
      transformed.should_not be_nil
      transformed.should be_kind_of my_api_smash
      transformed.name.should == "Bob"
      transformed.age.should == 18
    end

  end

end
