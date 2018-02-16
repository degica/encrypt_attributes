require 'spec_helper'

class Target
  include EncryptAttributes
  attr_accessor :encrypted_foo,
                :encrypted_blank,
                :encrypted_serialized,
                :encrypted_encoded,
                :encrypted_serialized_encoded,
                :encrypted_dynamic_key,
                :encrypted_create_accessors

  encrypted_attribute :foo, secret_key: 'secretkey'
  encrypted_attribute :blank, secret_key: 'secretkey', allow_blank: false
  encrypted_attribute :serialized, secret_key: 'secretkey', serialize: true
  encrypted_attribute :encoded, secret_key: 'secretkey', encode: true
  encrypted_attribute :serialized_encoded, secret_key: 'secretkey', encode: true, serialize: true
  encrypted_attribute :dynamic_key, secret_key: :dynamic_secret_key
  encrypted_attribute :create_accessors, secret_key: 'secretkey', serialize: { accessors: [:attribute1, "attribute2"] }

  def dynamic_secret_key
    "foobar"
  end
end

describe EncryptAttributes do
  let(:target) { Target.new }

  it "defines accessor methods" do
    target.foo = 'foo'
    expect(target.foo).to eq 'foo'
    expect(target.foo?).to be_truthy
  end

  it 'encrypt attributes' do
    value =  'value'
    target.foo = value
    expect(target.encrypted_foo).to be_instance_of String
    expect(target.foo).to eq value
  end

  context "when :allow_blank options is specified" do
    it "returns value when nil" do
      value =  nil
      target.blank = value
      expect(target.encrypted_blank).to be_instance_of NilClass
      expect(target.blank).to eq value
    end

    it "returns value when empty" do
      value =  ''
      target.blank = value
      expect(target.encrypted_blank).to be_instance_of String
      expect(target.blank).to eq value
    end
  end

  context "when secret_key options is a symbol" do
    it "encrypts the value using a secret key returned by a method" do
      value = 'value'
      target.dynamic_key = value
      expect(target.encrypted_dynamic_key).to be_instance_of String
      expect(target.dynamic_key).to eq value
    end
  end

  context 'when :serialize option is specified' do
    it 'serialize and encrypt' do
      value = {a: 1, b: 2}
      target.serialized = value
      expect(target.encrypted_serialized).to be_instance_of String
      expect(target.serialized).to eq value
    end
  end

  context 'when :encode option is specified' do
    it 'encode and encrypt' do
      value = 'あいうえお'
      target.encoded = value
      expect(target.encrypted_encoded).to be_instance_of String
      expect(target.encoded).to eq value
    end
  end

  context 'when :encode and :serialize option is specified' do
    it 'encode and encrypt' do
      value = {a: 'あいうえお'}
      target.serialized_encoded = value
      expect(target.encrypted_serialized_encoded).to be_instance_of String
      expect(target.serialized_encoded).to eq value
    end
  end

  context 'when :accessors option is specified in :serialize option' do
    it 'creates accessors' do
      expect(target.create_accessors_attribute1).to eq nil

      value = 'あいうえお'

      target.create_accessors_attribute1 = value
      expect(target.create_accessors).to eq ({ "attribute1" => value })
      expect(target.create_accessors_attribute1).to eq value

      target.create_accessors_attribute2 = "foo"
      expect(target.create_accessors).to eq ({ "attribute1" => value, "attribute2" => "foo" })

      target.create_accessors_attribute2 = "baz"
      expect(target.create_accessors).to eq ({ "attribute1" => value, "attribute2" => "baz" })
    end
  end
end
