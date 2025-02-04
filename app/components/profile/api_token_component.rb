class Profile::APITokenComponent < ApplicationComponent
  def initialize(api_token:, packed_token: nil)
    @api_token = api_token
    @packed_token = packed_token
  end

  private

  def procedures_to_allow_options
    @api_token.targetable_procedures.map { ["#{_1.id} – #{_1.libelle}", _1.id] }
  end

  def procedures_to_allow_select_options
    { selected: @api_token.targetable_procedures.first&.id }
  end
end
