context('Happy Guests', () => {
  it('guest searching', () => {
    cy.server() // so that we can control requests
    cy.route('GET', '/api/v1/listings**').as('getListings')

    cy.visit('/')
    cy.get('.LandingPageHero')
      .find('h1')
      .should('contain','Rent Apartments, Bedrooms & Coliving Spaces for Digital Nomads')

    cy.request('POST','/cypress/seed_properties.json').should((response) => {
      expect(response.body).to.have.property('result','seeded a guest, host, and property')
      cy.get('.DateRangePicker_Calendar_icon').click()
      cy.get('.CalendarMonthGrid_month__horizontal:nth-child(3)')
        .contains('1').click()
      cy.get('.CalendarMonthGrid_month__horizontal:nth-child(3)')
        .contains('1').click()


      cy.contains('SEARCH').click()
      cy.wait('@getListings')

      cy.contains('Filters')
      cy.get('.option-wrapper').contains('Lisbon').click()
      cy.contains('Portugal').click()
      cy.wait('@getListings')

      expect(response.body).to.have.property('listing')
      let listing = response.body.listing
      cy.get('.ListingsList').find('.ListingSummaryCard').invoke('text').should('include', listing.type)
      cy.visit('/listings/' + listing.id)
    })
  })

  it('guest signup and edit profile', () => {
    cy.visit('/')

    cy.request('POST','/cypress/cleanup_guests.json').should((response) => {
      expect(response.body).to.have.property('result','deleted all guests')
    })

    cy.contains('Sign Up').click()
    cy.location('pathname').should('be', '/signup')

    cy.get('[name="first_name"]').type('Jonny')
    cy.get('[name="last_name"]').type('Isaguest')
    cy.get('[name="email"]').type('jonny@example.com')
    cy.get('[name="password"]').type('password123!')
    cy.get('[name="password_confirmation"]').type('password123!{enter}')

    // add basic profile info
    cy.get('[name="profession"]').type('QA Analyst Extraordinaire')
    cy.get('[name="bio"]').type('This is my bio. It is awesome sauce.')

    const fileName = 'avatar.png'
    cy.fixture(fileName).then(fileContent => {
      cy.get('[name="avatar_url"]').upload({ fileContent, fileName, mimeType: 'image/png' });
    });

    cy.contains('Next').click()

    // complete the profile
    cy.location('pathname').should('be', '/my/profile/complete')
    cy.get('[name="birth_year"]').select('1974')
    cy.get('[name="gender"]').select('Other')
    cy.get('[name="country"]').select('Andorra')
    cy.get('[name="phone_number"]').type('+14045551212')

    cy.contains('Add a Language').click()
    cy.contains('English').click()
    cy.contains('Español').click()
    cy.contains('Save').click()

    cy.contains('Beer').click()
    cy.contains('Vegetarian').click()
    cy.contains('Save').click()

    // my profile page
    cy.location('pathname').should('be', '/my/profile')
    cy.get('.PublicProfile', { timeout: 10000}).find('h1').should('contain',"Hey, I'm Jonny Isaguest")
    cy.contains('Edit Profile').click()

    // edit profile
    cy.contains('Hiking').click()
    cy.contains('Submit').click()

    // my profile page again
    cy.location('pathname').should('be', '/my/profile')
    cy.get('li.PublicProfile__interest').invoke('text').should('include','Hiking')
    cy.contains('Edit Profile').click()

    // test the user dropdown
    cy.get('.profile-image.dropdown-toggle').click()
    cy.contains('My Properties').click()
    cy.location('pathname').should('be', '/my/listings')
    cy.get('.EmptyProperties').find('.heading').should('contain',"No properties")

    cy.get('.profile-image.dropdown-toggle').click()
    cy.contains('Favorite Listings').click()
    cy.location('pathname').should('be', '/listings/favorite')
    cy.get('.App').find('h2').should('contain',"Oops! You still don't have any favorites.")

    // change my password
    cy.get('.profile-image.dropdown-toggle').click()
    cy.contains('Settings').click()
    cy.location('pathname').should('be', '/my/settings')


    cy.on('uncaught:exception', (err, runnable) => {
      expect(err.message).to.include("Cannot read property 'submit' of null")
      return false
    })
    // TODO: Fails first time due to non-fatal JS exception
    // 'Cannot read property 'submit' of null' but no idea why
    cy.contains('Change Password').click()

    cy.location('pathname').should('be', '/my/settings/password')
    cy.get('[name="password"]', { timeout: 10000}).type('password456!')
    cy.get('[name="password_confirmation"]').type('password456!{enter}')
    cy.get('.FlashNotificationsItem.alert-success', { timeout: 10000}).should('contain','saved')

    // delete the profile
    cy.get('.profile-image.dropdown-toggle').click()
    cy.contains('My Profile').click()
    cy.contains('Edit Profile').click()
    cy.contains('Delete Profile', { timeout: 10000}).click()
    cy.get('[name="delete"]').type('boo')
    cy.get('.invalid-feedback').should('be',"You must type exactly 'delete'")
    cy.get('[name="delete"]').type('{backspace}{backspace}{backspace}delete')
    cy.contains('Delete Profile').click()
    cy.contains('Nuke it!').click()

    cy.location('pathname').should('be', '/')
  })

  it('guest reservation', () => {
    cy.server() // so that we can control requests
    cy.route('POST', '/api/v1/sessions**').as('sessions')
    cy.route('POST', '**reservations**').as('requestReservation')

    cy.request('POST','/cypress/seed_properties.json').should((response) => {
      expect(response.body).to.have.property('result','seeded a guest, host, and property')
      let guest = response.body.guest
      let host = response.body.host
      let listing = response.body.listing
      cy.visit('/listings/' + listing.id)
      cy.contains('Request Reservation').click()

      cy.get('[name="email"]').type(guest.email)
      cy.get('[name="password"]').type('password')
      cy.contains('LOG IN').click()
      cy.wait('@sessions')
      cy.contains('Request Reservation').click()

      cy.get('.DateInput_input').first().click()

      cy.get('.CalendarMonth[data-visible="true"]').eq(1)
        .find('td.CalendarDay[aria-disabled="false"]').first().click()

      cy.get('.CalendarMonth[data-visible="true"]').eq(2)
         .find('td.CalendarDay[aria-disabled="false"]').last().click()

      cy.wait(1000) // give the calendar picker time to disappear

      cy.get('.ReservationRequest [name=usermessage]').first()
        .type('Hey this is a guest NBD LOL.')

      cy.get('.ReservationRequest')
        .contains('Request Reservation').click()

      cy.wait("@requestReservation")

      cy.get('.ConversationMessage').first()
        .find('p').should('contain','Hey this is a guest NBD LOL.')

      cy.contains('Guests').next().invoke('text')
        .should('contain','1 person')

      cy.get('textarea.NewMessageForm__textarea')
        .type('Sorry, should have been more serious')

      cy.contains('Send').click()

      cy.get('.ConversationMessage').first().find('p')
        .should('contain','Sorry, should have been more serious')

      cy.get('.ConversationMessage').last().find('p')
        .should('contain','Hey this is a guest NBD LOL.')

      // note: it gets tricky when the same form appears multiple time due to responsive design
      cy.get('.ReservationRequestStatus.d-none')
        .contains('Modify Request').click()

      cy.get('select[name="number_of_guests"]').select('2')
        .closest('form')
        .contains('Modify').click()

      cy.contains('Guests').next().invoke('text')
        .should('contain','2 persons')

      cy.get('.profile-image.dropdown-toggle').click()
      cy.contains('Logout').click()

      cy.contains('Log in').click()
      cy.get('[name="email"]').type(host.email)
      cy.get('[name="password"]').type('password')
      cy.contains('LOG IN').click()
      cy.wait('@sessions')

      // todo: this link leads to /reservations which is for guests, not hosts
      // cy.contains('Reservations').click()

      // visit the host reservations page directly as a workaround
      cy.visit('/host/reservations')

      cy.get('.ReservationRequestsTable').invoke('text')
        .should('include','Reservation Pending')
        .should('include','Guest Nomadic')

      cy.contains('Review').click()
      cy.get('.ReservationRequestStatus.d-none')
        .contains('Accept').click()

      cy.get('[name=message]').first()
        .type('Alright.')
        .closest('form')
        .contains('Accept').click()

      cy.wait(1000)

      cy.get('.ReservationRequestStatus.d-none').find('h3')
        .should('contain','Thank you for accepting the reservation for Guest Nomadic')

      cy.get('.ConversationMessage').first().find('p')
        .should('contain','Alright.')

      cy.get('.profile-image.dropdown-toggle').click()
      cy.contains('Logout').click()

      cy.contains('Log in').click()
      cy.get('[name="email"]').type(guest.email)
      cy.get('[name="password"]').type('password')
      cy.contains('LOG IN').click()
      cy.wait('@sessions')

      cy.contains('Reservations').click()
      cy.get('.ReservationRequestCard')
        .find('h3').should('contain','Congratulations! Host Explorer accepted your request')

      cy.get('.ReservationRequestCard')
        .contains('Decline or Book').click()

      cy.get('.ReservationRequestStatus.d-none')
        .contains('Book Reservation').click()

      cy.contains(/^Book$/).click()

      cy.get('.SocialModal').last().find('h3')
        .should('contain','Congratulations your reservation is booked!')
    })
  })


})