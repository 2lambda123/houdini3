# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

describe QuerySupporters do
  describe '.campaign_list' do
    GIFT_LEVEL_ONE_TIME = 1111
    GIFT_LEVEL_RECURRING = 5585
    GIFT_LEVEL_CHANGED_RECURRING = 5512
    CAMPAIGN_GIFT_OPTION_NAME = "theowthoinv"
    let(:np) { force_create(:nonprofit)}
    let(:supporter1) { force_create(:supporter, nonprofit: np)}
    let(:supporter2) { force_create(:supporter, nonprofit: np)}
    let(:campaign) { force_create(:campaign, nonprofit: np, slug: "slug stuff")}
    let(:campaign_gift_option) { force_create(:campaign_gift_option, campaign: campaign, name: CAMPAIGN_GIFT_OPTION_NAME, amount_one_time: GIFT_LEVEL_ONE_TIME, amount_recurring: GIFT_LEVEL_RECURRING)}
    let(:campaign_gift1) { force_create(:campaign_gift, campaign_gift_option: campaign_gift_option, donation: donation1)}
    let(:donation1) { force_create(:donation, amount: GIFT_LEVEL_ONE_TIME, campaign: campaign, supporter:supporter1)}

    let(:payment1) {force_create(:payment, gross_amount: GIFT_LEVEL_ONE_TIME, donation: donation1)}

    let(:donation2)  {force_create(:donation, amount: GIFT_LEVEL_CHANGED_RECURRING, campaign: campaign, supporter:supporter2)}
    let(:payment2) {force_create(:payment, gross_amount: GIFT_LEVEL_RECURRING, donation: donation2)}
    let(:payment3) {force_create(:payment, gross_amount: GIFT_LEVEL_CHANGED_RECURRING, donation: donation2)}
    let(:campaign_gift2) { force_create(:campaign_gift, campaign_gift_option: campaign_gift_option, donation: donation2)}
    let(:recurring) {force_create(:recurring_donation, donation: donation2, amount: GIFT_LEVEL_CHANGED_RECURRING)}


    let(:init_all) {
      np
      supporter1
      supporter2
      campaign_gift1
      campaign_gift2
      recurring
      payment1
      payment2
      payment3
    }

    let(:campaign_list) {

      QuerySupporters.campaign_list(np.id, campaign.id, {page: 0})
    }

    before(:each) {
      init_all
    }

    it 'counts gift donations properly' do
      glm = campaign_list

      data = glm[:data]

      expect(data.map{|i| i['total_raised']}).to match_array([GIFT_LEVEL_ONE_TIME, GIFT_LEVEL_RECURRING])

    end
  end

  describe '.full_filter_expr' do

    let(:nonprofit) { force_create(:nonprofit)}
    let(:supporter1) { force_create(:supporter, nonprofit:nonprofit) }
    let(:supporter2) { force_create(:supporter, nonprofit:nonprofit) }

    describe 'search for by address' do
      let(:supporter_address) {force_create(:crm_address, supporter:supporter1, address: "515325 something st.", city:"Appleton", state_code: "WI", country: nil)}
      let(:supporter_address_2) {force_create(:crm_address, supporter:supporter1,  address: "515325 something st.", city:"Appleton", state_code: "il", country: "USA", zip_code: "5215890-RD")}
      let(:other_supporter_address) {force_create(:crm_address, supporter:supporter2, address: nil, city: "Chicago", state_code: "AZ", country: "Ireland")}

      let(:supporter_search_result) {
        supporter_address
        supporter_address_2
        other_supporter_address
        
        QuerySupporters.full_filter_expr(nonprofit.id,{location: 'Appl'}).select("supporters.id")
        .execute
      }

      it 'should have one supporter' do
        expect(supporter_search_result.count).to eq 1
      end

      it 'should have the correct supporter as output' do
        expect(supporter_search_result[0]['id']).to eq supporter1.id
      end
      
    end
  end

  describe '.get_supporter_by_default_address' do
    around(:each) do |example|
      Timecop.freeze(2020, 5, 4) do
          example.run
      end
    end
    let(:nonprofit) { force_create(:nonprofit)}
    let(:supporter1) { force_create(:supporter, nonprofit:nonprofit) }
    let(:supporter2) { force_create(:supporter, nonprofit:nonprofit) }

    let(:supporter_address) {force_create(:crm_address, supporter:supporter1,  address: "515325 something st.", city:"Appleton", state_code: "WI", country: nil)}
    let(:supporter_address_2) {force_create(:crm_address, supporter:supporter1,  address: "515325 something st.", city:"Appleton", state_code: "il", country: "USA", zip_code: "5215890-RD")}
    let(:other_supporter_address) {force_create(:crm_address, supporter:supporter2, address: nil, city: "Chicago", state_code: "AZ", country: "Ireland")}

    let(:address_tag1)  do
      force_create(:address_tag, 
        supporter:supporter1, 
        crm_address: supporter_address_2,
        name: 'default'
        )
    end
    
    let(:address_tag2)  do
      force_create(:address_tag, 
        supporter:supporter2, 
        crm_address: other_supporter_address,
        name: 'default'
        )
    end

    let(:supporters_with_default_address) do
      QuerySupporters.supporters_with_default_address(np_id: nonprofit.id).execute
    end

    let(:supporter1_attribs)  do
      supporter1.attributes.slice(
        'id', 
        'name',
        'email',
        'organization',
        'phone',
        'created_at',
        'imported_at',
        'anonymous',
        'is_unsubscribed_from_emails',
        'nonprofit_id'
         )
    end

    let(:supporter2_attribs) do
      supporter2.attributes.slice(
        'id', 
        'name',
        'email',
        'organization',
        'phone',
        'created_at',
        'imported_at',
        'anonymous',
        'is_unsubscribed_from_emails',
        'nonprofit_id'
         )
    end

    before(:each) do
      supporter1
      supporter2
      supporter_address
      supporter_address_2
      other_supporter_address

      address_tag1
      address_tag2

     
    end

    it 'should have two items' do
      expect(supporters_with_default_address.count).to eq 2
    end

    it 'should have correct address for supporter1' do
       attribs = supporter1_attribs.merge({
         'address': supporter_address_2.address,
         'city': supporter_address_2.city,
         'state_code': supporter_address_2.state_code,
         'zip_code': supporter_address_2.zip_code,
         'country': supporter_address_2.country
       })

       result = supporters_with_default_address.select{|i| i['id'] == supporter1.id}.first

       expect(h(result)).to eq h(attribs)
    end

    it 'should have correct address for supporter2' do
      
      attribs = supporter2_attribs.merge({
        'address': other_supporter_address.address,
        'city': other_supporter_address.city,
        'state_code': other_supporter_address.state_code,
        'zip_code': other_supporter_address.zip_code,
        'country': other_supporter_address.country
      })

      result = supporters_with_default_address.select{|i| i['id'] == supporter2.id}.first

      expect(h(result)).to eq h(attribs)
   end

  end

  describe '.for_info_card' do
    let(:nonprofit) { force_create(:nonprofit)}
    let(:supporter1) { force_create(:supporter, nonprofit:nonprofit) }
    let(:supporter2) { force_create(:supporter, nonprofit:nonprofit) }

    let(:supporter_address) {force_create(:crm_address, supporter:supporter1,  address: "515325 something st.", city:"Appleton", state_code: "WI", country: nil)}
    let(:supporter_address_2) {force_create(:crm_address, supporter:supporter1,  address: "515325 something st.", city:"Appleton", state_code: "il", country: "USA", zip_code: "5215890-RD")}
    let(:other_supporter_address) {force_create(:crm_address, supporter:supporter2, address: nil, city: "Chicago", state_code: "AZ", country: "Ireland")}


    let(:address_tag1)  do
      force_create(:address_tag, 
        supporter:supporter1, 
        crm_address: supporter_address_2,
        name: 'default'
        )
    end
    
    let(:address_tag2)  do
      force_create(:address_tag, 
        supporter:supporter2, 
        crm_address: other_supporter_address,
        name: 'default'
        )
    end
    
    let(:payments) do 
      force_create(:payment, gross_amount: 111, supporter: supporter1)
      force_create(:payment, gross_amount: 111, supporter: supporter2)
      force_create(:payment, gross_amount: 111, supporter: supporter1)
    end

    let(:info_card) do 
      supporter_address
      supporter_address_2
      other_supporter_address
      address_tag1
      address_tag2
      payments
      QuerySupporters.for_info_card(supporter1.id)
    end

    it 'should have a raised of 222' do
      expect(info_card['raised']).to eq 222
    end

    it 'should have an address of 515325 something st.' do
      expect(info_card['address']).to eq '515325 something st.'
    end

    it 'should have an state_code of il' do
      expect(info_card['state_code']).to eq 'il'
    end

    it 'should have a country USA' do
      expect(info_card['country']).to eq 'USA'
    end

    it 'should have a zip_code of 5215890-RD' do
      expect(info_card['zip_code']).to eq '5215890-RD'
    end

  end


  describe '.for_crm_profile' do
    let(:nonprofit) { force_create(:nonprofit)}
    let(:supporter1) { force_create(:supporter, nonprofit:nonprofit) }
    let(:supporter2) { force_create(:supporter, nonprofit:nonprofit) }

    let(:supporter_address) {force_create(:crm_address, supporter:supporter1,  address: "515325 something st.", city:"Appleton", state_code: "WI", country: nil)}
    let(:supporter_address_2) {force_create(:crm_address, supporter:supporter1,  address: "515325 something st.", city:"Appleton", state_code: "il", country: "USA", zip_code: "5215890-RD")}
    let(:other_supporter_address) {force_create(:crm_address, supporter:supporter2, address: nil, city: "Chicago", state_code: "AZ", country: "Ireland")}


    let(:address_tag1)  do
      force_create(:address_tag, 
        supporter:supporter1, 
        crm_address: supporter_address_2,
        name: 'default'
        )
    end
    
    let(:address_tag2)  do
      force_create(:address_tag, 
        supporter:supporter2, 
        crm_address: other_supporter_address,
        name: 'default'
        )
    end
    
    let(:payments) do 
      force_create(:payment, gross_amount: 111, supporter: supporter1)
      force_create(:payment, gross_amount: 111, supporter: supporter2)
      force_create(:payment, gross_amount: 111, supporter: supporter1)
    end

    let(:crm_profile) do 
      supporter_address
      supporter_address_2
      other_supporter_address
      address_tag1
      address_tag2
      payments
      QuerySupporters.for_crm_profile(nonprofit.id, [supporter1.id])
    end

    let(:supporter1_profile) do
      crm_profile[0]
    end

    it 'should have a raised of 222' do
      expect(supporter1_profile['raised']).to eq 222
    end

    it 'should have an address of 515325 something st.' do
      expect(supporter1_profile['address']).to eq '515325 something st.'
    end

    it 'should have an state_code of il' do
      expect(supporter1_profile['state_code']).to eq 'il'
    end

    it 'should have a country USA' do
      expect(supporter1_profile['country']).to eq 'USA'
    end

    it 'should have a zip_code of 5215890-RD' do
      expect(supporter1_profile['zip_code']).to eq '5215890-RD'
    end
  end
end
