module PolymorphicSubmitter
  extend ActiveSupport::Concern

  included do
    belongs_to :submitter, polymorphic: true, optional: true
    has_one :self_ref, class_name: "::#{name}", foreign_key: :id
    has_one :participant, through: :self_ref, source: :submitter, source_type: 'Participant'
    has_one :team, through: :self_ref, source: :submitter, source_type: 'Team'
  end
end
