# frozen_string_literal: true

class User < ActiveRecord::Base
  extend Devise::Models
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  include DeviseTokenAuth::Concerns::User

  ADMIN = 'admin'.freeze
  EMPLOYEE = 'employee'.freeze
  ROLES = [
    ADMIN,
    EMPLOYEE
  ].freeze

  MALE = 'male'.freeze
  FEMALE = 'female'.freeze
  GENDERS = [
    MALE,
    FEMALE
  ].freeze

  has_many :check_ins
  
  validates :email, presence: true, uniqueness: true
  validates :role, presence: true, inclusion: ROLES
  validates :gender, presence: true, inclusion: GENDERS

  scope :employees, -> { where(role: EMPLOYEE) }

  def admin?
    role == ADMIN
  end
end
