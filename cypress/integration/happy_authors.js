context("Happy Hosts", () => {
  it("host adds a private room", () => {
    cy.server(); // so that we can control requests
    cy.route("POST", "/api/v1/sessions**").as("sessions");
    cy.route("POST","/api/v1/properties**").as("properties");
    cy.route("PATCH","/api/v1/properties/*/submit").as("submit");
    cy.visit("/");

    cy.request("POST", "/cypress/seed_host.json").should(response => {
      expect(response.body).to.have.property("result", "seeded a host");

      cy.contains("Log in").click();
      cy.get('[name="email"]').type("host@example.com");
      cy.get('[name="password"]').type("password");
      cy.contains("LOG IN").click();
      cy.wait("@sessions");

      cy.get(".profile-image.dropdown-toggle").click();
      cy.contains("My Properties").click();
      cy.location("pathname").should("be", "/my/listings");

      cy.contains("Add New Property").click();

      cy.visit("/my/properties/new/shared_apartment");

      const fileName = "testimg.jpg";
      cy.fixture(fileName).then(fileContent => {
        cy.get(".NewPrivateRoom .ImageDropzone input")
          .first()
          .invoke("removeAttr", "style")
          .upload(
            { fileContent, fileName: "testimg.jpg", mimeType: "image/jpeg" },
            { subjectType: "input", force: true }
          );
      });

      cy.fixture(fileName).then(fileContent => {
        cy.get(".NewPrivateRoom .ImageDropzone input")
          .last()
          .invoke("removeAttr", "style")
          .upload(
            { fileContent, fileName: "testimg.jpg", mimeType: "image/jpeg" },
            { subjectType: "input", force: true }
          );
      });

      cy.get(".NewPrivateRoom")
        .find("[name=description]")
        .type("this is a description");

      cy.get(".NewPrivateRoom")
        .find("[name=address_line_1]")
        .type("Rua da Diabolo 666");

      cy.get(".NewPrivateRoom")
        .find("[name=city]")
        .type("Lisboa");

      cy.get(".NewPrivateRoom")
        .find("[name=region]")
        .type("Lisbon");

      cy.get(".NewPrivateRoom")
        .find("[name=country]")
        .select("Portugal");

      cy.get(".NewPrivateRoom")
        .contains("No Smoking")
        .click();

      cy.get(".NewPrivateRoom")
        .find("[name=wifi_speed]")
        .type("100");

      cy.get(".NewPrivateRoom")
        .find('[name="bedroom.title"]')
        .type("A STELLAR BEDROOM IN HELL");

      cy.get(".NewPrivateRoom")
        .find('[name="bedroom.text"]')
        .type("You are gonna be so warm and cozy. Just ignore the screams.");

      cy.get(".NewPrivateRoom")
        .find('[name="bedroom.summary"]')
        .type("You are gonna be so warm and cozy. Muahahaha.");

      cy.get(".NewPrivateRoom")
        .find('[name="bedroom.price"]')
        .type("666");

      // todo: define some unavailable weeks
      // cy.get('.CalendarMonthGrid_month__horizontal ').eq(2).find('[aria-disabled="false"]').first().click()
      // cy.get('.CalendarMonthGrid_month__horizontal ').eq(2).find('[aria-disabled="false"]').last().click()

      cy.contains("Save and Submit").click();

      cy.wait("@properties")
      cy.wait("@submit")

      cy.location("pathname").should("be", "/my/listings");

      cy.get(".alert.alert-warning").should(
        "contain",
        "Your completed listings will appear as search results once the property has been approved"
      );
    });
  });

  it("host adds a private apartment", () => {
    cy.server(); // so that we can control requests
    cy.route("POST", "/api/v1/sessions**").as("sessions");
    cy.route("POST","/api/v1/properties**").as("properties");
    cy.route("PATCH","/api/v1/properties/*/submit").as("submit");

    cy.visit("/");

    cy.request("POST", "/cypress/seed_host.json").should(response => {
      expect(response.body).to.have.property("result", "seeded a host");

      cy.contains("Log in").click();
      cy.get('[name="email"]').type("host@example.com");
      cy.get('[name="password"]').type("password");
      cy.contains("LOG IN").click();
      cy.wait("@sessions");

      cy.get(".profile-image.dropdown-toggle").click();
      cy.contains("My Properties").click();
      cy.location("pathname").should("be", "/my/listings");

      cy.contains("Add New Property").click();

      // todo: hey Richard I couldn't figure out how to click on the button

      cy.visit("/my/properties/new/private_apartment");

      const fileName = "testimg.jpg";
      cy.fixture(fileName).then(fileContent => {
        cy.get(".NewPrivateApartment .ImageDropzone input")
          .first()
          .invoke("removeAttr", "style")
          .upload(
            { fileContent, fileName: "testimg.jpg", mimeType: "image/jpeg" },
            { subjectType: "input", force: true }
          );
      });

      cy.get(".NewPrivateApartment")
        .find("[name=title]")
        .type("this is a title");

      cy.get(".NewPrivateApartment")
        .find("[name=description]")
        .type("this is a description");

      cy.get(".NewPrivateApartment")
        .find("[name=address_line_1]")
        .type("Rua da Diabolo 666");

      cy.get(".NewPrivateApartment")
        .find("[name=city]")
        .type("Lisboa");

      cy.get(".NewPrivateApartment")
        .find("[name=region]")
        .type("Lisbon");

      cy.get(".NewPrivateApartment")
        .find("[name=country]")
        .select("Portugal");

      cy.get(".NewPrivateApartment")
        .contains("No Smoking")
        .click();

      cy.get(".NewPrivateApartment")
        .find("[name=wifi_speed]")
        .type("100");

      cy.get(".NewPrivateApartment")
        .find("[name=number_of_rooms]")
        .type("2");

      // todo: define some unavailable weeks
      // cy.get('.CalendarMonthGrid_month__horizontal ').eq(2).find('[aria-disabled="false"]').first().click()
      // cy.get('.CalendarMonthGrid_month__horizontal ').eq(2).find('[aria-disabled="false"]').last().click()

      cy.get(".NewPrivateApartment")
        .find('[name="price"]')
        .type("666");

      cy.get(".NewPrivateApartment")
        .find('[name="deposit"]')
        .select("One month's rent");

      cy.get(".NewPrivateApartment")
        .find('[name="external_urls[0]"]')
        .type("https://airbnb.com/rooms/w487934897342789");

      cy.get(".NewPrivateApartment")
        .contains("Add another external URL")
        .click();

      cy.get(".NewPrivateApartment")
        .find('[name="external_urls[1]"]')
        .type("https://booking.com/u/3kdj3kj/38293882393");

      cy.contains("Save and Submit").click();

      cy.wait("@properties")
      cy.wait("@submit")

      cy.location("pathname").should("be", "/my/listings");

      cy.get(".alert.alert-warning").should(
        "contain",
        "Your completed listings will appear as search results once the property has been approved"
      );
    });
  });
});
