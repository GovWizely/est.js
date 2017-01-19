RSpec.describe 'est', type: :feature, js: true do
  context 'when visiting est page without parameter' do
    before do
      visit '/production.html'
      find_field 'Environmental Issue (12)'
    end

    it 'renders all filters' do
      within '#est' do
        expect(page).to have_select 'Environmental Issue (12)',
                                    selected: 'Select an option',
                                    with_options: [
                                      'Arsenic Remediation in Drinking Water',
                                      'Universal Waste'
                                    ]

        expect(page).to have_select 'EPA Regulation (12)',
                                    selected: 'Select an option',
                                    with_options: [
                                      'Clean Water Act',
                                      'Standards of Performance for New Stationary Sources: Oil and Gas'
                                    ]

        expect(page).to have_select 'Solution (95)',
                                    selected: 'Select an option',
                                    with_options: [
                                      'Absorption Towers',
                                      'Thickening Technology or Processes'
                                    ]

        expect(page).to have_select 'U.S. Solution Provider (89)',
                                    selected: 'Select an option',
                                    with_options: [
                                      'ABCOV',
                                      'ZAPS Technologies, Inc.'
                                    ]
      end
    end
  end

  context 'when selecting an issue' do
    before do
      visit '/production.html'
      page.select 'Universal Waste', from: 'Environmental Issue (12)'
      find_field 'EPA Regulation (1)'
    end

    it 'updates the page title and URL' do
      expect(page).to have_title 'Environmental Solutions Toolkit'
      expect(page).to have_current_path('/production.html?issue_ids=12')
    end

    it 'filters select boxes' do
      within '#est' do
        expect(page).to have_select 'Environmental Issue (12)',
                                    selected: 'Universal Waste',
                                    with_options: [
                                      'Arsenic Remediation in Drinking Water',
                                      'Universal Waste'
                                    ]

        expect(page).to have_select 'EPA Regulation (1)',
                                    selected: 'Standards for Universal Waste Management'

        expect(page).to have_select 'Solution (4)',
                                    selected: 'Select an option',
                                    with_options: [
                                      'CRT Recycling Technology',
                                      'Related Technologies for Standards for Universal Waste Management: Universal Waste'
                                    ]

        expect(page).to have_select 'U.S. Solution Provider (5)',
                                    selected: 'Select an option',
                                    with_options: [
                                      'ABCOV',
                                      'LoadMan On-Board Weight Scales and Systems'
                                    ]
      end
    end

    it 'renders results' do
      find :xpath, ".//div[@id='estIssues']//h4[text()='Universal Waste']"

      within '#estIssues' do
        expect(page).to have_text 'The universal waste rule provides streamlined management'
        expect(page).to have_link 'U.S. Environmental Protection Agency Regulatory Background',
                                  href: 'https://archive.epa.gov/epawaste/hazard/web/html/laws-2.html'
        expect(page).to have_link 'U.S. Environmental Protection Agency Research and Analysis',
                                  href: 'https://www.epa.gov/hw/universal-waste'
      end

      within '#estRegulations' do
        expect(page).to have_link 'Standards for Universal Waste Management',
                                  href: 'http://www.gpo.gov/fdsys/pkg/CFR-2012-title40-vol28/pdf/CFR-2012-title40-vol28-part273.pdf'
      end

      within '#estSolutionsProviders' do
        expect(page).to have_selector 'table td',
                                      text: 'Lamp Crushing Systems'
        expect(page).to have_link 'Air Cycle Corporation',
                                  href: 'http://www.aircycle.com/'
      end
    end
  end

  context 'when visiting a page with a predefined filter' do
    before do
      visit '/production.html?provider_ids=11'
      find_field 'Environmental Issue (4)'
    end

    it 'filters select boxes' do
      within '#est' do
        expect(page).to have_select 'Environmental Issue (4)',
                                    selected: 'Select an option',
                                    with_options: [
                                      'Groundwater Remediation',
                                      'Secondary or Advanced Wastewater Treatment'
                                    ]

        expect(page).to have_select 'EPA Regulation (4)',
                                    selected: 'Select an option',
                                    with_options: [
                                      'Clean Water Act',
                                      'Standards of Performance for New Stationary Sources: Landfills and Municipal Waste'
                                    ]

        expect(page).to have_select 'Solution (4)',
                                    selected: 'Select an option',
                                    with_options: [
                                      'Landfill Groundwater Monitoring',
                                      'Related Technologies for Clean Water Act: Groundwater Remediation'
                                    ]

        expect(page).to have_select 'U.S. Solution Provider (89)',
                                    selected: 'ANDalyze',
                                    with_options: [
                                      'ABCOV',
                                      'ZAPS Technologies, Inc.'
                                    ]
      end
    end

    it 'renders results' do
      find :xpath, ".//div[@id='estIssues']//h4[text()='Groundwater Remediation']"

      within '#estIssues' do
        expect(page).to have_xpath ".//h4[text()='Secondary or Advanced Wastewater Treatment']"
        expect(page).to have_text 'Groundwater is the source of water found in wells'
        expect(page).to have_link 'U.S. Environmental Protection Agency Regulatory Background',
                                  href: 'https://www.epa.gov/dwreginfo/ground-water-rule'
        expect(page).to have_link 'U.S. Environmental Protection Agency Research and Analysis',
                                  href: 'https://www.epa.gov/sites/production/files/2015-10/documents/regulatory_impact_analysis_for_the_proposed_ground_water_rule.pdf'

        expect(page).to have_text 'An important aspect of municipal wastewater'
        expect(page).to have_link 'U.S. Environmental Protection Agency Regulatory Background',
                                  href: 'https://www.epa.gov/eg'
        expect(page).to have_link 'Decision Memorandum Regarding Non-uniform Secondary Treatment Standards',
                                  href: 'http://www.epa.gov/npdes/pubs/ow_shapiro_nrdcpetition.pdf'
      end

      within '#estRegulations' do
        expect(page).to have_link 'Clean Water Act',
                                   href: 'https://www.epa.gov/laws-regulations/summary-clean-water-act'
        expect(page).to have_link 'Standards of Performance for New Stationary Sources: Landfills and Municipal Waste',
                                  href: 'http://www.gpo.gov/fdsys/pkg/CFR-2011-title40-vol6/xml/CFR-2011-title40-vol6-part60.xml'
      end

      within '#estSolutionsProviders' do
        expect(page).to have_selector 'table td', text: 'Landfill Groundwater Monitoring'
        expect(page).to have_link 'ANDalyze',
                                  href: 'www.andalyze.com'
      end
    end
  end

  context 'when using the Clear button' do
    before do
      visit '/production.html?provider_ids=11'
      find :xpath, ".//div[@id='estIssues']//h4[text()='Groundwater Remediation']"

      click_on 'Clear'
      find_field 'Environmental Issue (12)'
    end

    it 'shows disclaimer' do
      expect(find_by_id('estDisclaimer').text).to include('Disclaimer')
    end
  end

  context 'when using the browser history' do
    before do
      visit '/production.html?provider_ids=11'
      find :xpath, ".//div[@id='estIssues']//h4[text()='Groundwater Remediation']"

      page.select 'ABCOV', from: 'U.S. Solution Provider (89)'
      find :xpath, ".//div[@id='estIssues']//h4[text()='Universal Waste']"

      page.evaluate_script 'window.history.back()'
    end

    it 'restores the results' do
      find :xpath, ".//div[@id='estIssues']//h4[text()='Groundwater Remediation']"
    end
  end
end
