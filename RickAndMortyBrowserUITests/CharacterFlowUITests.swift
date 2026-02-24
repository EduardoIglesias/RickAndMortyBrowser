//
//  CharacterFlowUITests.swift
//  RickAndMortyBrowser
//
//  Created by Eduardo Iglesias Fernandez on 24/2/26.
//

import XCTest

final class CharacterFlowUITests: XCTestCase {

    func test_listRowShowsNameStatusAndAvatar_thenDetailShowsRequiredFields() {
        let app = XCUIApplication()
        app.launch()

        // Espera a que aparezca la lista
        let firstCell = app.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10))

        // Verifica que el row contiene los elementos requeridos
        XCTAssertTrue(firstCell.staticTexts["characterRow.name"].exists)
        XCTAssertTrue(firstCell.staticTexts["characterRow.status"].exists)
        let avatar = firstCell.descendants(matching: .any)["characterRow.avatar"]
        XCTAssertTrue(avatar.exists)


        // Tap en la primera celda para ir al detalle
        firstCell.tap()

        // Verifica campos requeridos del detalle
        XCTAssertTrue(app.staticTexts["characterDetail.name"].waitForExistence(timeout: 10))

        XCTAssertTrue(app.staticTexts["characterDetail.status.value"].exists)
        XCTAssertTrue(app.staticTexts["characterDetail.species.value"].exists)
        XCTAssertTrue(app.staticTexts["characterDetail.gender.value"].exists)
        XCTAssertTrue(app.staticTexts["characterDetail.currentlocation.value"].exists)
        XCTAssertTrue(app.staticTexts["characterDetail.origin.value"].exists)
    }

    func test_filterDoesNotBreakDetail() {
        let app = XCUIApplication()
        app.launch()

        // Abre el search
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 10))

        searchField.tap()
        searchField.typeText("Rick")

        // Selecciona el primer resultado tras filtrar
        let firstCell = app.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10))
        firstCell.tap()

        // Detalle debe cargar
        XCTAssertTrue(app.staticTexts["characterDetail.name"].waitForExistence(timeout: 10))
    }
}
