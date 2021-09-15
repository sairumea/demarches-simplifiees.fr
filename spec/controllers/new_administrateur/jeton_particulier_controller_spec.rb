describe NewAdministrateur::JetonParticulierController, type: :controller do
  let(:admin) { create(:administrateur) }
  let(:procedure) { create(:procedure, administrateur: admin) }

  before do
    stub_const("API_PARTICULIER_URL", "https://particulier.api.gouv.fr/api")

    sign_in(admin.user)
  end

  describe "GET #api_particulier" do
    let(:procedure) { create :procedure, :with_service, administrateur: admin }

    render_views

    subject { get :api_particulier, params: { procedure_id: procedure.id } }

    it { is_expected.to have_http_status(:success) }
    it { expect(subject.body).to have_content('Jeton API particulier') }
  end

  describe "GET #show" do
    subject { get :show, params: { procedure_id: procedure.id } }

    it { is_expected.to have_http_status(:success) }
  end

  describe "PATCH #update" do
    let(:params) { { procedure_id: procedure.id, procedure: { api_particulier_token: token } } }

    subject { patch :update, params: params }

    context "when jeton has a valid shape" do
      let(:token) { "d7e9c9f4c3ca00caadde31f50fd4521a" }
      before do
        VCR.use_cassette(cassette) do
          subject
        end
      end

      context "and the api response is a success" do
        let(:cassette) { "api_particulier/success/introspect" }

        it { expect(flash.alert).to be_nil }
        it { expect(flash.notice).to eq("Le jeton a bien été mis à jour") }
        it { expect(procedure.reload.api_particulier_token).to eql(token) }
      end

      context "and the api response is not unauthorized" do
        let(:cassette) { "api_particulier/unauthorized/introspect" }

        it { expect(flash.alert).to include("Mise à jour impossible : le jeton n'a pas été trouvé ou n'est pas actif") }
        it { expect(flash.notice).to be_nil }
        it { expect(procedure.reload.api_particulier_token).not_to eql(token) }
      end
    end

    context "when jeton is invalid and no call is made" do
      let(:token) { "jet0n 1nvalide" }

      before { subject }

      it { expect(flash.alert).to include("Mise à jour impossible : le jeton n'est pas valide") }
      it { expect(flash.notice).to be_nil }
      it { expect(procedure.reload.api_particulier_token).not_to eql(token) }
    end
  end
end
