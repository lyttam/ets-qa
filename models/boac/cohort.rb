class Cohort

  attr_accessor :id, :name, :owner_uid, :members, :member_data

  def initialize(cohort_data)
    cohort_data.each { |k, v| public_send("#{k}=", v) }
  end

end
