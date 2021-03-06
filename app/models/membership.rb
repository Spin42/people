class Membership
  include Mongoid::Document
  include Mongoid::Timestamps
  include Membership::UserAvailability

  field :starts_at, type: Time
  field :ends_at, type: Time
  field :billable, type: Mongoid::Boolean

  belongs_to :user
  belongs_to :project
  belongs_to :role

  validates :user, presence: true
  validates :project, presence: true
  validates :role, presence: true
  validates :starts_at, presence: true
  validates :billable, inclusion: { in: [true, false] }

  validate :validate_starts_at_ends_at
  validate :validate_duplicate_project

  scope :with_role, ->(role) { where(role: role) }
  scope :with_user, ->(user) { where(user: user) }
  scope :unfinished, -> { any_of({ ends_at: nil }, { :ends_at.gt => Time.current }) }
  scope :finished, -> { lte(ends_at: Time.current) }
  scope :ending_soon, -> { between(ends_at: Time.now..1.week.from_now) }
  scope :billable, -> { where(billable: true) }

  %w(user project role).each do |model|
    original_model = "original_#{model}"
    alias_method original_model, model

    define_method(model) do
      model.capitalize.constantize.unscoped { send original_model }
    end
  end

  def started?
    starts_at < Time.now
  end

  def terminated?
    ends_at.try('<', Time.now) || false
  end

  def active?
    started? && !terminated?
  end

  def ends_at=(new_date)
    if new_date.present?
      ends_at_time = Time.zone.parse(new_date.to_s)
      ends_at_time = ends_at_time.end_of_day - 1.second if ends_at_time == ends_at_time.beginning_of_day
      write_attribute(:ends_at, ends_at_time)
    else
      write_attribute(:ends_at, nil)
    end
  end

  def starts_at=(new_date)
    if new_date.present?
      starts_at_time = Time.zone.parse(new_date.to_s)
      if starts_at? && starts_at_time == starts_at.beginning_of_day
        write_attribute(:starts_at, starts_at)
      else
        write_attribute(:starts_at, starts_at_time)
      end
    end
  end

  def end_now!
    update(ends_at: Time.now)
  end

  private

  def validate_starts_at_ends_at
    if starts_at.present? && ends_at.present? && starts_at > ends_at
      errors.add(:ends_at, "can't be before starts_at date")
    end
  end

  def validate_duplicate_project
    memberships = Membership.with_user(user).not_in(:_id => [id]).where(project_id: project.try(:id))
    if ends_at.present?
      duplicate = memberships.or({ :starts_at.lte => ends_at, :ends_at.gte => starts_at }, { :starts_at.lte => ends_at, :ends_at => nil })
    else
      duplicate = memberships.or({ ends_at: nil }, { :ends_at.gte => starts_at })
    end

    errors.add(:project, "user is not available at given time for this project") if duplicate.exists?
  end
end
