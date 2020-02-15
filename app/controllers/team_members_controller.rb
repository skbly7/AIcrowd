class TeamMembersController < ApplicationController
  def index
    @section_to_member_hash                                                      = Hash.new []
    @description_list                                                            = Hash.new []
    TeamMember.order(:seq).each { |x| @section_to_member_hash[x.section.upcase] += [x] }
    @description_list['AICROWD RESEARCH FELLOWS']                                =
      "AIcrowd Research Fellows collaborate on challenges by helping with in-house research on novel problems and designing baselines."
  end
end
