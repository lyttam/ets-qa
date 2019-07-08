require_relative '../../util/spec_helper'

module BOACStudentPageAdvisingNote

  include PageObject
  include Logging
  include Page
  include BOACPages
  include BOACPagesCreateNoteModal

  #### EXISTING NOTES ####

  button(:notes_button, id: 'timeline-tab-note')
  button(:show_hide_notes_button, id: 'timeline-tab-note-previous-messages')
  elements(:note_msg_row, :div, xpath: '//div[contains(@id,"timeline-tab-note-message")]')
  elements(:topic, :list_item, xpath: '//li[contains(@id, "topic")]')

  # Clicks the Notes tab and expands the list of notes
  def show_notes
    logger.info 'Checking notes tab'
    wait_for_update_and_click notes_button_element
    wait_for_update_and_click show_hide_notes_button_element if show_hide_notes_button? && show_hide_notes_button_element.text.include?('Show')
  end

  # Returns the expected sort order of a student's notes
  # @param notes [Array<Note>]
  # @return [Array<String>]
  def expected_note_id_sort_order(notes)
    (notes.sort_by {|n| [n.updated_date, n.created_date, n.id] }).reverse.map &:id
  end

  # Returns the expected format for a collapsed note date
  # @return [String]
  def expected_note_short_date_format(date)
    (Time.now.strftime('%Y') == date.strftime('%Y')) ? date.strftime('%b %-d') : date.strftime('%b %-d, %Y')
  end

  # Returns the expected format for an expanded note date
  # @return [String]
  def expected_note_long_date_format(date)
    format = (Time.now.strftime('%Y') == date.strftime('%Y')) ? date.strftime('%b %-d %l:%M%P') : date.strftime('%b %-d, %Y %l:%M%P')
    format.gsub(/\s+/, ' ')
  end

  # Returns the visible sequence of note ids
  # @return [Array<String>]
  def visible_collapsed_note_ids
    els = browser.find_elements(xpath: '//div[contains(@id, "note-")][contains(@id, "-is-closed")]')
    els.map do |el|
      parts = el.attribute('id').split('-')
      (parts[2] == 'is') ? parts[1] : parts[1..2].join('-')
    end
  end

  # Returns the note element visible when the note is collapsed
  # @param note [Note]
  # @return [PageObject::Elements::Div]
  def collapsed_note_el(note)
    div_element(id: "note-#{note.id}-is-closed")
  end

  # Returns the button element for collapsing a given note
  # @param note [Note]
  # @return [PageObject::Elements::Button]
  def close_msg_button(note)
    button_element(xpath: "//div[@id='note-#{note.id}-is-closed']/../following-sibling::div/button")
  end

  # Returns the visible note date when the note is collapsed
  # @param note [Note]
  # @return [Hash]
  def visible_collapsed_note_data(note)
    subject_el = div_element(id: "note-#{note.id}-is-closed")
    date_el = div_element(id: "collapsed-note-#{note.id}-created-at")
    {
      :subject => (subject_el.attribute('innerText').gsub("\n", '') if subject_el.exists?),
      :date => (date_el.text.gsub(/\s+/, ' ') if date_el.exists?)
    }
  end

  # Whether or not a given note is expanded
  # @param note [Note]
  # @return [boolean]
  def note_expanded?(note)
    div_element(id: "note-#{note.id}-is-open").exists?
  end

  # Expands a note unless it's already expanded
  # @param note [Note]
  def expand_note(note)
    if note_expanded? note
      logger.debug "Note ID #{note.id} is already expanded"
    else
      logger.debug "Expanding note ID #{note.id}"
      wait_for_update_and_click_js collapsed_note_el(note)
    end
  end

  # Expands a note unless it's already expanded
  # @param note_subject [String]
  def expand_note_by_subject(note_subject)
    note_el = span_element(xpath: "//span[text()=\"#{note_subject}\"]/..")
    wait_for_update_and_click note_el
  end

  # Collapses a note unless it's already collapsed
  # @param note [Note]
  def collapse_note(note)
    if note_expanded? note
      logger.debug "Collapsing note ID #{note.id}"
      wait_for_update_and_click close_msg_button(note)
    else
      logger.debug "Note ID #{note.id} is already collapsed"
    end
  end

  # Returns the element containing the note's advisor name
  # @param note [Note]
  # @return [PageObject::Elements::Link]
  def note_advisor_el(note)
    link_element(id: "note-#{note.id}-author-name")
  end

  # Attachments

  element(:sorry_no_attachment_msg, xpath: '//body[text()="Sorry, attachment not available."]')

  # Returns the element containing a given attachment name
  # @param attachment_name [String]
  # @return [Array<PageObject::Elements::Element>]
  def note_attachment_el(note, attachment_name)
    note_attachment_els(note).find { |el| el.text.strip == attachment_name }
  end

  # Returns the elements containing both downloadable and non-downloadable note attachments
  # @param note [Note]
  # @return [Array<Selenium::WebDriver::Element>]
  def note_attachment_els(note)
    spans = browser.find_elements(xpath: "//li[contains(@id, 'note-#{note.id}-attachment')]//span[contains(@id, '-attachment-')]")
    links = browser.find_elements(xpath: "//li[contains(@id, 'note-#{note.id}-attachment')]//a[contains(@id, '-attachment-')]")
    spans + links
  end

  # Downloads an attachment and returns the file size, deleting the file once downloaded. If the download is not available,
  # logs a warning and moves on if a SIS note or logs and error and fails if a Boa note.
  # @param note [Note]
  # @param attachment [Attachment]
  # @param student [BOACUser]
  # @return [Integer]
  def download_attachment(note, attachment, student=nil)
    logger.info "Downloading attachment '#{attachment.id}' from note ID #{note.id}"
    Utils.prepare_download_dir
    wait_until(Utils.short_wait) { note_attachment_els(note).any? }
    note_attachment_el(note, attachment.file_name).click
    file_path = "#{Utils.download_dir}/#{attachment.file_name}"
    wait_until(Utils.medium_wait) { sorry_no_attachment_msg? || Dir[file_path].any?  }

    if sorry_no_attachment_msg?
      # Get back on the student page for subsequent tests
      load_page student
      show_notes

      if attachment.sis_file_name
        logger.warn "Cannot download SIS note ID #{note.id} attachment ID '#{attachment.id}'"
        nil
      else
        logger.error "Cannot download Boa note ID #{note.id} attachment ID '#{attachment.id}'"
        fail
      end

    else
      file = File.new file_path

      # If the attachment file size is known (i.e., it was uploaded as part of the test), then make sure the download reaches the same size.
      if attachment.file_size
        wait_until(Utils.medium_wait) do
          logger.debug "File size is currently #{file.size}, waiting until it reaches #{attachment.file_size}"
          file.size == attachment.file_size
        end
      end
      size = file.size

      # Zap the download dir again to make sure no attachment downloads are left behind on the test machine
      Utils.prepare_download_dir
      size
    end
  end

  # Returns the file input for adding an an attachment to an existing note
  # @param note [Note]
  # @return [PageObject::Elements::TextArea]
  def existing_note_attachment_input(note)
    text_area_element(xpath: "//div[@id='note-#{note.id}-attachment-dropzone']/input")
  end

  # Returns the delete button for an attachment on an existing note
  # @param note [Note]
  # @param attachment [Attachment]
  # @return [PageObject::Elements::Button]
  def existing_note_attachment_delete_button(note, attachment)
    list_item_element(xpath: "//div[@id=\"note-#{note.id}-outer\"]//li[contains(., \"#{attachment.file_name}\")]//button")
  end

  # Adds a attachments to an existing note
  # @param note [Note]
  # @param attachments [Array<Attachment>]
  def add_attachments_to_existing_note(note, attachments)
    attachments.each do |attach|
      logger.debug "Adding attachment '#{attach.file_name}' to note ID #{note.id}"
      existing_note_attachment_input(note).when_present 1
      existing_note_attachment_input(note).send_keys Utils.asset_file_path(attach.file_name)
      existing_note_attachment_delete_button(note, attach).when_present Utils.short_wait
      sleep Utils.click_wait
      note.updated_date = Time.now
      note.attachments << attach
    end
  end

  # Removes attachments from an existing note
  # @param note [Note]
  # @param attachments [Array<Attachment>]
  def remove_attachments_from_existing_note(note, attachments)
    attachments.each do |attach|
      logger.info "Removing attachment '#{attach.file_name}' from note ID #{note.id}"
      wait_for_update_and_click existing_note_attachment_delete_button(note, attach)
      confirm_delete_or_discard
      existing_note_attachment_delete_button(note, attach).when_not_visible Utils.short_wait
      note.attachments.delete attach
      attach.deleted_at = Time.now
      note.updated_date = Time.now
    end
  end


  # Metadata

  # Returns the data visible when the note is expanded
  # @param note [Note]
  # @return [Hash]
  def visible_expanded_note_data(note)
    sleep 2
    body_el = span_element(id: "note-#{note.id}-message-open")
    advisor_role_el = span_element(id: "note-#{note.id}-author-role")
    advisor_dept_els = span_elements(xpath: "//span[contains(@id, 'note-#{note.id}-author-dept-')]")
    topic_els = topic_elements.select { |el| el.attribute('id').include? "note-#{note.id}-topic-" }
    topic_remove_btn_els = topic_remove_btn_elements.select { |el| el.attribute('id').include? "remove-note-#{note.id}-topic" }
    created_el = div_element(id: "expanded-note-#{note.id}-created-at")
    updated_el = div_element(id: "expanded-note-#{note.id}-updated-at")
    permalink_el = link_element(id: "advising-note-permalink-#{note.id}")
    # The body text area contains formatting elements even without text, so account for that when getting the element's text
    body_text = if body_el.exists?
                  text = body_el.attribute('innerText')
                  text.gsub(/\W/, '').gsub('&nbsp;', '').empty? ? '' : text
                else
                  ''
                end
    {
      :body => body_text.gsub("\n", '').strip,
      :advisor => (note_advisor_el(note).text if note_advisor_el(note).exists?),
      :advisor_role => (advisor_role_el.text if advisor_role_el.exists?),
      :advisor_depts => advisor_dept_els.map(&:text).sort,
      :topics => topic_els.map(&:text).sort,
      :remove_topics_btns => topic_remove_btn_els,
      :attachments => (note_attachment_els(note).map { |el| el.attribute('innerText').strip }).sort,
      :created_date => (created_el.text.strip.gsub(/\s+/, ' ') if created_el.exists?),
      :updated_date => (updated_el.text.strip.gsub(/\s+/, ' ') if updated_el.exists?),
      :permalink_url => (permalink_el.attribute('href') if permalink_el.exists?)
    }
  end

  # Verifies the visible content of a note
  # @param note [Note]
  def verify_note(note)
    logger.debug "Verifying visible data for note ID #{note.id}"

    # Verify data visible when note is collapsed
    collapsed_note_el(note).when_present Utils.medium_wait
    collapse_note note
    visible_data = visible_collapsed_note_data note
    expected_short_updated_date = "Last updated on #{expected_note_short_date_format note.updated_date}"
    wait_until(1, "Expected '#{note.subject}', got #{visible_data[:subject]}") { visible_data[:subject] == note.subject }
    wait_until(1, "Expected '#{expected_short_updated_date}', got #{visible_data[:date]}") { visible_data[:date] == expected_short_updated_date }

    # Verify data visible when note is expanded
    expand_note note
    visible_data.merge!(visible_expanded_note_data note)
    wait_until(1, "Expected '#{note.body}', got '#{visible_data[:body]}'") { visible_data[:body] == "#{note.body}" }
    wait_until(1, 'Expected non-blank advisor name') { !visible_data[:advisor].empty? }
    wait_until(1, 'Expected non-blank advisor role') { !visible_data[:advisor_role].empty? }
    wait_until(1, "Expected '#{note.advisor.depts}', got #{visible_data[:advisor_depts]}") { visible_data[:advisor_depts] == note.advisor.depts }

    # Topics
    note_topics = (note.topics.map { |t| t.name.upcase }).sort
    wait_until(1, "Expected '#{note_topics}', got #{visible_data[:topics]}") { visible_data[:topics] == note_topics }
    wait_until(1, "Expected no remove-topic buttons, got #{visible_data[:remove_topics_btns].length}") { visible_data[:remove_topics_btns].length.zero? }

    # Attachments
    non_deleted_attachments = note.attachments.reject &:deleted_at
    expected_file_names = non_deleted_attachments.map &:file_name
    wait_until(1, "Expected '#{expected_file_names.sort}', got #{visible_data[:attachments].sort}") { visible_data[:attachments].sort == expected_file_names.sort }

    # Check visible timestamps within 1 minute to avoid failures caused by a 1 second diff
    expected_long_created_date = "Created on #{expected_note_long_date_format note.created_date}"
    wait_until(1, "Expected '#{expected_long_created_date}', got #{visible_data[:created_date]}") do
      Time.parse(visible_data[:created_date]) <= Time.parse(expected_long_created_date) + 60
      Time.parse(visible_data[:created_date]) >= Time.parse(expected_long_created_date) - 60
    end
    expected_long_updated_date = "Last updated on #{expected_note_long_date_format note.updated_date}"
    wait_until(1, "Expected '#{expected_long_updated_date}', got #{visible_data[:updated_date]}") do
      Time.parse(visible_data[:updated_date]) <= Time.parse(expected_long_updated_date) + 60
      Time.parse(visible_data[:updated_date]) >= Time.parse(expected_long_updated_date) - 60
    end
  end

  #### EDIT / DELETE ####

  # Returns the edit note button element for a given note
  # @param note [Note]
  # @return [PageObject::Elements::Button]
  def edit_note_button(note)
    button_element(id: "edit-note-#{note.id}-button")
  end

  # Returns the delete note button element for a given note
  # @param note [Note]
  # @return [PageObject::Elements::Button]
  def delete_note_button(note)
    button_element(xpath: "//tr[descendant::div/@id=\"note-#{note.id}-is-open\"]//button[@id=\"delete-note-button\"]")
  end

  # Clicks the edit button for a given note
  # @param note [Note]
  def click_edit_note_button(note)
    logger.debug 'Clicking the Edit Note button'
    wait_for_update_and_click edit_note_button(note)
  end

  # Obtains the ID of a new note and sets current created and updated dates. Fails if the note ID is not available within a defined
  # timeout
  # @param note [Note]
  # @return [Integer]
  def set_new_note_id(note)
    new_note_subject_input_element.when_not_visible Utils.short_wait
    id = ''
    start_time = Time.now
    wait_until(15) do
      id, note.id = BOACUtils.get_note_ids_by_subject(note.subject).first
    end
    logger.debug "Note ID is #{id}"
    logger.warn "Note was created in #{Time.now - start_time} seconds"
    note.created_date = note.updated_date = Time.now
    id
  rescue
    logger.debug 'Timed out waiting for note ID'
    fail
  end

  # Edits an existing note's subject and updated date
  # @param note [Note]
  def edit_note_subject_and_save(note)
    logger.info "Changing note ID #{note.id} subject to '#{note.subject}'"
    expand_note note
    click_edit_note_button note
    enter_edit_note_subject note
    click_save_note_edit
    collapsed_note_el(note).when_visible Utils.short_wait
    note.updated_date = Time.now
  end

  # Deletes a note and sets the deleted date
  # @param note [Note]
  def delete_note(note)
    logger.info "Deleting note '#{note.id}'"
    expand_note note
    wait_for_update_and_click delete_note_button(note)
    confirm_delete_or_discard
    note.deleted_date = Time.now
  end

  # Subject

  text_area(:edit_note_subject_input, id: 'edit-note-subject')
  span(:subj_required_msg, xpath: '//span[text()="Subject is required"]')

  # Enters the subject text for an edit to an existing note
  # @param note [Note]
  def enter_edit_note_subject(note)
    logger.debug "Entering edited note subject '#{note.subject}'"
    wait_for_element_and_type(edit_note_subject_input_element, note.subject)
  end

  # Save

  button(:edit_note_save_button, id: 'save-note-button')

  # Clicks the save note edit button
  def click_save_note_edit
    logger.debug 'Clicking the edit note Save button'
    wait_for_update_and_click edit_note_save_button_element
  end

  # Cancel

  button(:edit_note_cancel_button, id: 'cancel-edit-note-button')

  # Clicks the cancel note edit button
  def click_cancel_note_edit
    logger.debug 'Clicking the edit note Cancel button'
    wait_for_update_and_click edit_note_cancel_button_element
  end

  #### CREATE NOTE, STUDENT PROFILE ####

  button(:new_note_button, id: 'new-note-button')
  button(:new_note_minimize_button, id: 'minimize-new-note-modal')

  # Clicks the new note button
  def click_create_new_note
    logger.debug 'Clicking the New Note button'
    wait_for_update_and_click new_note_button_element
  end

  # Combines methods to create a note with subject, body, attachments, topics, ID, and created/updated dates
  # @param note [Note]
  # @param topics [Array<Topic>]
  # @param attachments [Array<Attachment>]
  def create_note(note, topics, attachments)
    click_create_new_note
    enter_new_note_subject note
    enter_note_body note
    add_attachments_to_new_note(note, attachments)
    add_topics(note, topics)
    click_save_new_note
    set_new_note_id note
  end

end
