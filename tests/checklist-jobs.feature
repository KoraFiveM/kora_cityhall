# Converted from the communitybot legacy tests by kora-qa-panel/scripts/convert-legacy.mjs.
# The """ block under each Scenario is the original test text, verbatim. Review before applying.
Feature: kora_cityhall — Jobs

  @kora_cityhall @checklist @checklist:kora_cityhall:cityhall-ped-blip @cat:jobs
  Scenario: City Services ped and map blip
    """
    Checklist test: Go to -264,-966,30 (Legion Square area); ped with scenario is present and a City Services blip shows on the map.
    """
    When I go to "legion_square"
    Then I confirm: a ped with a scenario is present at the City Hall
    And I confirm: a City Services blip shows on my map

  @kora_cityhall @checklist @checklist:kora_cityhall:open-menu @cat:jobs
  Scenario: Open City Hall menu via target
    """
    Checklist test: Target the clerk ped and select 'City Hall'; NUI panel opens on the right with ID Card and Job Center tabs.
    """
    When I manually: go to the City Hall clerk ped
    And I manually: target the clerk ped
    And I select the "City Hall" target option
    Then the "qb-cityhall:kiosk" app opens
    And I confirm: the NUI panel opens on the right with ID Card and Job Center tabs

  @kora_cityhall @checklist @checklist:kora_cityhall:buy-id-card @cat:jobs
  Scenario: Buy ID card ($50)
    """
    Checklist test: Identity tab, Purchase on ID Card; $50 cash taken and id_card item added with your name, birthdate, gender, nationality.
    """
    Given my cash balance is 500
    When I manually: go to the City Hall clerk ped
    And I manually: open the City Hall menu, go to the Identity tab and click Purchase on ID Card
    Then my cash balance should have changed by -50
    And I should have 1 "id_card"
    And I confirm: the id_card item shows my name, birthdate, gender and nationality

  @kora_cityhall @checklist @checklist:kora_cityhall:buy-driver-license @cat:jobs
  Scenario: Buy driver license ($100)
    """
    Checklist test: Identity tab, Purchase on Driver License; $100 cash taken, item shows 'Class C Driver License' info.
    """
    Given my cash balance is 500
    When I manually: go to the City Hall clerk ped
    And I manually: open the City Hall menu, go to the Identity tab and click Purchase on Driver License
    Then my cash balance should have changed by -100
    And I should have 1 "driver_license"
    And I confirm: the driver license item shows 'Class C Driver License' info

  @kora_cityhall @checklist @checklist:kora_cityhall:buy-weapon-license @cat:jobs
  Scenario: Buy weapon license ($200)
    """
    Checklist test: Identity tab, Purchase on Weapon License; $200 cash taken, weaponlicense item added with your info.
    """
    Given my cash balance is 500
    When I manually: go to the City Hall clerk ped
    And I manually: open the City Hall menu, go to the Identity tab and click Purchase on Weapon License
    Then my cash balance should have changed by -200
    And I should have 1 "weaponlicense"
    And I confirm: the weaponlicense item shows my info

  @kora_cityhall @checklist @checklist:kora_cityhall:insufficient-cash @cat:jobs
  Scenario: Not enough cash on purchase
    """
    Checklist test: Try buying a license with less cash than the price; error notification shows required amount and nothing is given.
    """
    Given my cash balance is 10
    When I manually: go to the City Hall clerk ped
    And I manually: open the City Hall menu, go to the Identity tab and click Purchase on a license
    Then I should see an error notification
    And I confirm: the error notification shows the required amount
    And my cash balance should have changed by 0
    And I should have no "id_card"
    And I should have no "driver_license"
    And I should have no "weaponlicense"

  @kora_cityhall @checklist @checklist:kora_cityhall:full-inventory @cat:jobs
  Scenario: Inventory full blocks purchase
    """
    Checklist test: Fill inventory then purchase a license; 'inventory is full' error and money is not lost (refunded).
    """
    Given my cash balance is 500
    When I manually: fill my inventory until it is full
    And I manually: go to the City Hall clerk ped
    And I manually: open the City Hall menu and click Purchase on a license
    Then I should see an error notification
    And I confirm: the error says the inventory is full
    And my cash balance should have changed by 0

  @kora_cityhall @checklist @checklist:kora_cityhall:too-far-rejected @cat:jobs
  Scenario: Purchase only works near the hall
    """
    Checklist test: Trigger a purchase while far from the ped (>5m); server rejects it.
    """
    Given my cash balance is 500
    When I manually: open the City Hall menu, then walk more than 5m away from the ped
    And I manually: click Purchase on a license
    Then I confirm: the server rejects the purchase
    And my cash balance should have changed by 0

  @kora_cityhall @checklist @checklist:kora_cityhall:apply-job @cat:jobs
  Scenario: Apply for a government job
    """
    Checklist test: Job Center tab, Apply on trucker/taxi/tow/reporter/garbage/bus/hotdog; success notification and job added at grade 1.
    """
    When I manually: go to the City Hall clerk ped
    And I manually: open the City Hall menu, go to the Job Center tab and click Apply on a job (trucker, taxi, tow, reporter, garbage, bus or hotdog)
    Then I should see a notification containing "You have successfully applied for the job."
    And I confirm: my job was added at grade 1

  @kora_cityhall @checklist @checklist:kora_cityhall:job-list @cat:jobs @manual
  Scenario: Job list shows labels
    """
    Checklist test: Job Center tab lists all 7 configured jobs with their job labels and an Apply button each.
    """
    When I manually: go to the City Hall clerk ped
    And I manually: open the City Hall menu and go to the Job Center tab
    Then I confirm: all 7 configured jobs are listed with their job labels
    And I confirm: each job has an Apply button

  @kora_cityhall @checklist @checklist:kora_cityhall:starter-items @cat:jobs @manual
  Scenario: Claim starter items once
    """
    Checklist test: On a new character the server hands out starter items (ID, license) via getIds; relogging or repeating does not duplicate them.
    """
    When I manually: create a new character and receive the starter items (ID, license)
    Then I confirm: the starter items (ID, license) were handed out
    When I manually: relog and repeat the claim
    Then I confirm: the starter items are not duplicated

  @kora_cityhall @checklist @checklist:kora_cityhall:qb-compat-events @cat:jobs @needs:admin @manual
  Scenario: QB-compat client events open nearest hall
    """
    Checklist test: Trigger qb-cityhall:client:openCityhallMenu / openIdentityMenu / openJobMenu from another resource; the menu opens.
    """
    When I manually: go to the City Hall clerk ped
    And I manually: as a Mod, run a client-side console command that triggers the event qb-cityhall:client:openCityhallMenu
    Then I confirm: the City Hall menu opens
    When I manually: as a Mod, run a client-side console command that triggers the event qb-cityhall:client:openIdentityMenu
    Then I confirm: the Identity menu opens
    When I manually: as a Mod, run a client-side console command that triggers the event qb-cityhall:client:openJobMenu
    Then I confirm: the Job menu opens
