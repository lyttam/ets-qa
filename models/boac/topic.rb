class Topic

  attr_accessor :name, :for_notes, :for_appts

  def initialize(name, for_notes, for_appts)
    @name = name
    @for_notes = for_notes
    @for_appts = for_appts
  end

  TOPICS = [
      ACADEMIC_DIFFICULTY = new('Academic Difficulty', true, false),
      ACADEMIC_INTERESTS = new('Academic Interests', true, false),
      ACADEMIC_PLAN = new('Academic Plan', true, false),
      ACADEMIC_PROGRESS = new('Academic Progress', true, false),
      ACADEMIC_PROGRESS_RPT = new('Academic Progress Report (APR)', true, false),
      ACADEMIC_SUPPORT = new('Academic Support', true, false),
      ADVISING_HOLDS = new('Advising Holds', true, true),
      AP_IB_GCE_TEST_UNITS = new('AP/IB/GCE test units', true, false),
      APPEAL_PROCEDURES = new('Appeal Procedures', false, true),
      BREADTH_REQTS = new('Breadth requirement(s)', true, false),
      CAREER_INTERNSHIP = new('Career/Internship', true, false),
      CAREER_PLANNING = new('Career Planning', false, true),
      CHANGE_GRADING_OPTION = new('Change Grading Option', true, false),
      CHANGE_OF_COLLEGE = new('Change of College', true, true),
      CHANGE_OF_MAJOR = new('Change of Major', true, false),
      COCI = new('COCI', true, false),
      CONCURRENT_ENROLLMENT = new('Concurrent Enrollment', true, true),
      CONTINUED_AFTER_DISMISSAL = new('Continued After Dismissal', true, false),
      COURSE_ADD = new('Course Add', true, true),
      COURSE_DROP = new('Course Drop', true, true),
      COURSE_GRADE_OPTION = new('Course Grade Option', true, false),
      COURSE_SELECTION = new('Course Selection', true, false),
      COURSE_UNIT_CHANGE = new('Course Unit Change', true, false),
      CRISIS_ADVISING = new('Crisis Advising', false, true),
      CURRENTLY_DISMISSED_PLANNING = new('Currently Dismissed/Planning', true, false),
      DEAN_APPT = new('Dean Appointment', true, false),
      DEGREE_CHECK = new('Degree Check', true, true),
      DEGREE_CHECK_PREP = new('Degree Check Preparation', true, false),
      DEGRESS_REQTS = new('Degree Requirements', true, false),
      DISMISSAL = new('Dismissal', true, false),
      DOUBLE_MAJOR = new('Double Major', true, true),
      EAP = new('Education Abroad Program (EAP)', true, false),
      EAP_RECIPROCITY = new('Education Abroad Program (EAP) Reciprocity', true, false),
      EDUCATIONAL_GOALS = new('Educational Goals', true, false),
      ELIGIBILITY = new('Eligibility', true, false),
      ENROLLING_ANOTHER_SCHOOL = new('Enrolling At Another School', true, false),
      EVAL_COURSES_ELSEWHERE = new('Evaluation of course(s) taken elsewhere', true, false),
      EXCESS_UNITS = new('Excess Units', true, true),
      FINANCIAL_AID_BUDGETING = new('Financial Aid/Budgeting', true, false),
      GRADUATE_ADVISING = new('Graduate Advising', false, true),
      GRADUATION_CHECK = new('Graduation Check', true, false),
      GRADUATION_PLAN = new('Graduation Plan', true, false),
      GRADUATION_PROGRESS = new('Graduation Progress', true, false),
      INCOMPLETES = new('Incompletes', true, false),
      JOINT_MAJOR = new('Joint Major', true, false),
      LATE_ENROLLMENT = new('Late Enrollment', true, false),
      MAJORS = new('Majors', true, false),
      MIN_UNIT_PROGRAM = new('Minimum Unit Program', true, false),
      MINORS = new('Minors', true, false),
      PASS_NO_PASS = new('Pass / Not Pass (PNP)', true, false),
      PERSONAL = new('Personal', true, false),
      PETITION = new('Petition', true, false),
      POST_GRADUATION = new('Post-Graduation', true, false),
      PREMED_PRE_HEALTH_ADVISING = new('Premed/Pre-Health Advising', true, false),
      PROBATION = new('Probation', true, true),
      PROCTORING = new('Proctoring', true, false),
      PROGRAM_PLANNING = new('Program Planning', true, false),
      READING_AND_COMP = new('Reading & Composition', true, false),
      READMISSION = new('Readmission', true, true),
      READMISSION_AFTER_DISMISSAL = new('Readmission After Dismissal', true, false),
      REFER_TO_ACAD_DEPT = new('Refer to Academic Department', true, false),
      REFER_TO_CAREER_CENTER = new('Refer to Career Center', true, false),
      REFER_TO_RESOURCES = new('Refer to Resources', true, false),
      REFER_TO_TANG_CENTER = new('Refer to The Tang Center', true, false),
      REQUIREMENTS = new('Requirements', true, false),
      RESEARCH = new('Research', true, false),
      RETROACTIVE_ADD = new('Retroactive Add', true, true),
      RETROACTIVE_DROP = new('Retroactive Drop', true, true),
      RETROACTIVE_UNIT_CHANGE = new('Retroactive Unit Change', true, true),
      RETROACTIVE_WITHDRAWAL = new('Retroactive Withdrawal', true, true),
      SAT_ACAD_PROGRESS_APPEAL = new('Satisfactory Academic Progress (SAP) Appeal', true, false),
      SCHEDULING = new('Scheduling', true, false),
      SEMESTER_OUT_RULE = new('Semester Out Rule', true, false),
      SENIOR_RESIDENCY = new('Senior Residency', true, false),
      SIMULTANEOUS_DEGREE = new('Simultaneous Degree', true, false),
      SPECIAL_STUDIES = new('Special Studies', true, false),
      STUDENT_CONDUCT = new('Student Conduct', true, false),
      STUDENT_FACULTY_MEDIATION = new('Student/Faculty mediation', false, true),
      STUDY_ABROAD = new('Study Abroad', true, false),
      TRANSFER_COURSEWORK = new('Transfer Coursework', true, false),
      TRANSITION_SUPPORT = new('Transition Support', true, false),
      TRAVEL_CONFLICTS = new('Travel Conflicts', true, false),
      WAIVE_COLLECT_REQT = new('Waive College Requirement', true, false),
      WITHDRAWAL = new('Withdrawal', true, true),
      OTHER = new('Other / Reason not listed', true, true)
  ]

end
