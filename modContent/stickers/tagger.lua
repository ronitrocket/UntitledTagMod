SMODS.Sticker {
    key = "tagger",
    
    -- This refers to the atlas keys defined in atlas.lua. It is NOT necessarily the name of the image atlas file.
    atlas = "stickerAtlas",
   
    -- This is the position of the sticker icon on the sticker atlas.
    pos = {x=0, y=0},

    -- Config for the sticker.
    config = {
        extra = {
            mult = 10,
        }
    },
    

    -- CURRENTLY NOT USED BECAUSE ANYTHING OTHER THAN 0, 0 WILL GET FUCKED UP LOOKING WHEN THE CARD IS RENDERED AT DIFFERENT SIZES (e.g deck view)
    -- The pos of the sticker on the card. (very finnicky will try and make it normalized so 0, 0 is top left and 1, 1 is bottom right,)
    sticker_position = {x=0.2, y=1.7},
   
    -- Lets the sticker be compatible with all cards.
    default_compat = true,

    -- The color of the badge (e.g when mousing over a card, the color of the background where the name of the sticker is).
    badge_colour = G.C.RED,

    -- Prevent the sticker from appearing naturally.
    rate = 0,
    
    --This is used by the localization file to get the variables for the sticker to display in the UI. (e.g. vars = {card.ability.mult} means #1# in the localization file will be replaced with the value of card.ability.mult)
    loc_vars = function(self, info_queue, card)
        return {
          vars = {
            self.config.extra.mult
          }
        }
    end,

    -- The apply function for the sticker. If val is true, the sticker is applied to the card. If val is false, the sticker is removed from the card.
    apply = function(self, card, val)
        if val then
            card.ability[self.key] = copy_table(self.config)
        else
            card.ability[self.key] = nil
        end
    end,

    -- Dark magic function to draw the sticker sprite but scaled down. One day this beast will be tamed.
    draw = function(self, card, layer)
        -- card.children.front.scale.x = card.children.front.scale.x/2;
        -- card.children.front.scale.y = card.children.front.scale.y/2;
        self.send_to_shader = self.send_to_shader or {}
        self.send_to_shader[1] = math.min(card.VT.r*3, 1) + G.TIMERS.REAL/(28) + (card.juice and card.juice.r*20 or 0) + card.tilt_var.amt
        self.send_to_shader[2] = G.TIMERS.REAL
        --self.sprite = Sprite(0, 0, 0, 0, G.ASSET_ATLAS['untitledtagmod_stickerAtlas'], {x = 0, y = 0})
        --print('a'..card.children.center.scale_mag)
        --card.children.center.scale_mag = card.children.center.scale_mag*1.5
        --print('b'..(card.children.center.scale_mag/1.5))
        --print((card.children.center.scale_mag/1.5)/(34.53/self.sticker_position.x))
        --print((card.children.center.scale_mag/1.5)/(34.53/self.sticker_position.y))
        -- self.sticker_sprite:draw_shader('dissolve', 1, nil, nil, card.children.center, 0, 0, (card.children.center.scale_mag/1.5)/(34.53/(self.sticker_position.x+.1)), (card.children.center.scale_mag/1.5)/(34.53/(self.sticker_position.y+.1)))
        -- self.sticker_sprite:draw_shader('dissolve', nil, nil, nil, card.children.center, 0, 0, (card.children.center.scale_mag/1.5)/(34.53/self.sticker_position.x), (card.children.center.scale_mag/1.5)/(34.53/self.sticker_position.y))
        -- self.sticker_sprite:draw_shader('voucher', nil, self.send_to_shader, nil, card.children.center, 0, 0, (card.children.center.scale_mag/1.5)/(34.53/self.sticker_position.x), (card.children.center.scale_mag/1.5)/(34.53/self.sticker_position.y))
        self.sticker_sprite:draw_shader('dissolve', 1, nil, nil, card.children.center, -.35, 0, -.15, -.15)
        self.sticker_sprite:draw_shader('dissolve', nil, nil, nil, card.children.center, -.35, 0, -.2, -.2)
        self.sticker_sprite:draw_shader('voucher', nil, nil, nil, card.children.center, -.35, 0, -.2, -.2)
        --card.children.center.scale_mag = card.children.center.scale_mag/1.5
    end,

    -- Calculate function for the sticker.
    calculate = function(self, card, context)
        -- card.children.front.scale.x = card.children.front.scale.x/2;
        -- card.children.front.scale.y = card.children.front.scale.y/2;
        -- If the context is after scoring, and the cardarea is the play area, continue.
        if context.after and context.cardarea == G.play then
            -- Loop through the scoring hand.
            for index, otherCard in ipairs(context.scoring_hand) do
                -- If we found our card, continue.
                if card == otherCard then
                    -- If the next card exists, continue.
                    if (index + 1) >= #context.scoring_hand then
                        index = 1
                    end
                    -- For some reason, using an event like is the only way to get the card to have the visual effect of being tagged happen along with the text. No idea why.
                    G.E_MANAGER:add_event(Event({
                        func = function() 
                            -- Apply the sticker to the next card.
                            SMODS.Stickers[self.key]:apply(context.scoring_hand[index + 1], true);
                            -- Remove the sticker from the current card.
                            SMODS.Stickers[self.key]:apply(card, false);
                            return true 
                        end
                    }))
                    -- Return the message to display when the sticker is applied.
                    return {
                        message = 'Tagged!',
                        message_card = context.scoring_hand[index + 1],
                        colour = G.C.RED,
                    }
                end
            end
        end

        if context.after and context.cardarea == G.hand then
            -- Loop through the scoring hand.
            for index, otherCard in ipairs(G.hand) do
                -- If we found our card, continue.
                if card == otherCard then
                    -- If the next card exists, continue.
                    if (index + 1) >= #G.hand then
                        index = 1
                    end
                    -- For some reason, using an event like is the only way to get the card to have the visual effect of being tagged happen along with the text. No idea why.
                    G.E_MANAGER:add_event(Event({
                        func = function() 
                            -- Apply the sticker to the next card.
                            SMODS.Stickers[self.key]:apply(context.scoring_hand[index + 1], true);
                            -- Remove the sticker from the current card.
                            SMODS.Stickers[self.key]:apply(card, false);
                            return true 
                        end
                    }))
                    -- Return the message to display when the sticker is applied.
                    return {
                        message = 'Tagged!',
                        message_card = context.scoring_hand[index + 1],
                        colour = G.C.RED,
                    }
                end
            end
        end
       
        -- If the context is main scoring, and the cardarea is the play area, add the mult for whatever card.ability[self.key].extra.mult is.
        if context.main_scoring and context.cardarea == G.play then
            return {
                mult = card.ability[self.key].extra.mult
            }
        end
    end,
}