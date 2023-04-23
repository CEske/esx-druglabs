ConfigServer = {
    admingroup = 'admin', -- Hvilken gruppe skal kunne oprette labs?
    Shells = {
        -- ["NAVN"] = {
        --     obj = `OBJECT`,
        --     ["farm"] = {
        --         item = 'ITEM', -- hvilket item skal de få? 
        --         amount_given = 0     
        --     },
        --     ["process"] = {
        --         item = 'fish', -- hvilket item skal de få?
        --         amount_required = 4, -- hvor mange items skal de have?
        --         amount_given = 1 -- hvor mange items skal de få?
        --     },
        --     ["pack"] = {
        --         item = 'wool', -- hvilket item skal de få?
        --         amount_required = 2, -- hvor mange items skal de have?
        --         amount_given = 1 -- hvor mange items skal de få?
        --     }
        -- },
        ["coke"] = {
            obj = `k4coke_shell`,
            ["farm"] = {
                item = 'fabric', 
                amount_given = 0     
            },
            ["process"] = {
                item = 'fish',
                amount_required = 4,
                amount_given = 1
            },
            ["pack"] = {
                item = 'wool',
                amount_required = 2,
                amount_given = 1
            }
        },
        ["weed"] = {
            obj = `k4weed_shell`,
            ["farm"] = {
                item = '',
                amount_given = 0     
            },
            ["process"] = {
                item = '',
                amount_required = 0,
                amount_given = 0
            },
            ["pack"] = {
                item = '',
                amount_required = 0,
                amount_given = 0
            }
        },
        ["meth"] = {
            obj = `k4meth_shell`,
            ["farm"] = {
                item = '',
                amount_given = 0     
            },
            ["process"] = {
                item = '',
                amount_required = 0,
                amount_given = 0
            },
            ["pack"] = {
                item = '',
                amount_required = 0,
                amount_given = 0
            }
        },
    },
    whitelisted_gangs = { -- liste af jobs som kan raide labs udover politiet
        'taxi',
    }
}