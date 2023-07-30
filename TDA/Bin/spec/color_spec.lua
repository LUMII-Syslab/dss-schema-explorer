require("color")

describe("color conversion utilities for graph diagram engine", function()
	it("should convert primary colors correctly", function()
		local tda_red = 255
		local tda_green = 65280
		local tda_blue = 16711680

		assert.equal(tda_red, color.rgb_to_tda_int(255, 0, 0))
		assert.equal(tda_green, color.rgb_to_tda_int(0, 255, 0))
		assert.equal(tda_blue, color.rgb_to_tda_int(0, 0, 255))
	end)
	it("should get the same results when going round", function()
		local r, g, b = color.random_hue_rgb(0.5, 0.95)
		assert.is_number(r)
		assert.is_number(g)
		assert.is_number(b)

		local tda_color_int = color.rgb_to_tda_int(r, g, b)
		assert.is_number(tda_color_int)

		local r_back, g_back, b_back = color.tda_to_rgb_int(tda_color_int)
		assert.is_number(r_back)
		assert.is_number(g_back)
		assert.is_number(b_back)


		assert.are.equal(r, r_back)
		assert.are.equal(g, g_back)
		assert.are.equal(b, b_back)
	end)
end)