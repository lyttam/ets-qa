require_relative '../../util/spec_helper'

class BOACGroupPage

  include PageObject
  include Logging
  include Page
  include BOACPages
  include BOACListViewPages
  include BOACCohortPages

  span(:grp_not_found_msg, xpath: '//span[contains(.,"No curated group found with id: ")]')
  text_area(:rename_group_input, id: 'rename-input')

  # Loads a group
  # @param group [CuratedGroup]
  def load_page(group)
    navigate_to "#{BOACUtils.base_url}/curated_group/#{group.id}"
    wait_for_spinner
  end

  # Returns the error message element shown when a user attempts to view a group it does not own
  # @param user [User]
  # @param group [CuratedGroup]
  def no_group_access_msg(user, group)
    span_element(xpath: "//span[text()='Current user, #{user.uid}, does not own curated group #{group.id}']")
  end

  # Renames a group
  # @param group [CuratedGroup]
  # @param new_name [String]
  def rename_grp(group, new_name)
    logger.info "Changing the name of group ID #{group.id} to #{new_name}"
    load_page group
    wait_for_load_and_click rename_cohort_button_element
    group.name = new_name
    wait_for_element_and_type(rename_group_input_element, new_name)
    wait_for_update_and_click rename_cohort_confirm_button_element
    span_element(xpath: "//span[text()=\"#{group.name}\"]").when_present Utils.short_wait
  end

  # Removes a student from a group
  # @param row_index [Number]
  def remove_student_by_row_index(row_index)
    wait_for_student_list
    wait_for_update_and_click button_element(:id => "row-#{row_index}-remove-student-from-curated-group")
    group.members.delete student
    sleep 2
    wait_until(Utils.short_wait) { list_view_uids.sort == group.members.map(&:uid).sort }
    wait_for_sidebar_group_member_count group
  end

end
