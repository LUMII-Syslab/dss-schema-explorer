describe("Busted unit testing framework", function()
	describe("should be awesome", function()
		it("should be easy to use", function()
			assert.truthy("Yup.")
		end)

		it("should have lots of features", function()
			-- deep check comparisons!
			assert.same({ table = "great"}, { table = "great" })

			-- or check by reference!
			assert.is_not.equals({ table = "great"}, { table = "great"})

			assert.falsy(nil)
			assert.error(function() error("Wat") end)
		end)

		it("should provide some shortcuts to common functions", function()
			assert.unique({{ thing = 1 }, { thing = 2 }, { thing = 3 }})
		end)

		it("should have mocks and spies for functional tests", function()
			local thing = require("thing_module")
			spy.spy_on(thing, "greet")
			thing.greet("Hi!")

			assert.spy(thing.greet).was.called()
			assert.spy(thing.greet).was.called_with("Hi!")
		end)

		it("should fail", function()
			assert.truthy(false)
		end)
	end)

	describe("busted pending tests", function()
		pending("I should finish this test later", function() end)
	end)
end)