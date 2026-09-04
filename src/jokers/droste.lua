local mod = SMODS.current_mod

SMODS.Joker{
    key='droste',
    atlas = 'droste',
    pos = {
        x = 0,
        y = 0
    },
    config = {
        extra = {
            x_mult = 1,
            odds = 1,
        }
    },
    rarity = 2,
    cost = 8,
    loc_vars = function(self, info_queue, card)

        --multiply both by four to get rid of the decimal fraction
        --simplify the fraction
        --to simplify:
        -- find gcf
        -- divide both top and bottom by GCF

        local numerator = G.GAME.probabilities.normal
        local denominator = card.ability.extra.odds

        if mod.config.simplify_decimal_fractions then
            numerator = numerator * 4
            denominator = denominator * 4

            local divisor = gcf(numerator, denominator)
            numerator = numerator / divisor
            denominator = denominator / divisor
        end

        return {
            vars = {
                numerator,
                denominator,
                card.ability.extra.x_mult + 1, --x_mult of next Joker
                card.ability.extra.x_mult, --current x_mult
            }
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                x_mult = card.ability.extra.x_mult
            }
        end

        if context.selling_self then
            if pseudorandom('droste') < G.GAME.probabilities.normal / card.ability.extra.odds then
                local new_card = SMODS.copy_card(card, {
                    no_add = true --don't add a glitched extra duplicate to our jokers list
                })

                --upgrade the stuff
                new_card.ability.extra.odds = card.ability.extra.odds + 0.25
                new_card.ability.extra.x_mult = card.ability.extra.x_mult + 1

                --calculate new sprite sheet location so he wears a different hat
                positions = {
                    { 0, 0 },
                    { 0, 1 },
                    { 0, 2 },
                    { 1, 0 },
                    { 1, 1 },
                    { 1, 2 },
                    { 2, 0 },
                    { 2, 1 },
                }

                local sprite_pos = card.children.center.sprite_pos
                --very likely a better way to do this but whatever
                for index, value in ipairs(positions) do
                    if sprite_pos.x == value[1] and sprite_pos.y == value[2] then
                        new_index = (index + 1) % #positions
                        if new_index == 0 then
                            new_index = 1 --thanks Lua
                        end

                        new_pos = positions[new_index]
                        new_card.children.center:set_sprite_pos({x = new_pos[1], y = new_pos[2]})
                        break
                    end
                end

                new_card:add_to_deck()
                G.jokers:emplace(new_card)

                return {
                    message = "Droste!"
                }
            else
                return {
                    message = "Nope!"
                }
            end
        end
    end
}

function gcf(first, second)
    first_factors = factors(first)
    second_factors = factors(second)

    for i = #first_factors, 1, -1 do
        for j = #second_factors, 1, -1 do
            if first_factors[i] == second_factors[j] then
                return first_factors[i]
            end
        end
    end
end

function factors(number)
    local the_factors = {}
    for i = 1, number / 2 do
        if number % i == 0 then
            table.insert(the_factors, i)
        end
    end
    table.insert(the_factors, number)
    return the_factors
end