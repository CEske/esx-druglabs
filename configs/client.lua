ConfigClient = {
    Shells = { -- liste af shells
        -- ["NAVN"] = {
        --     obj = `INDSÆT`, -- object
        --     door = vector3(x, y, z), -- Hvor skal man spawne?
        --     pak = vector3(x, y, z), -- Hvor skal man pakke
        --     process = vector3(x, y, z) -- Hvor skal man process
        --     farm = vector3(x, y, z), -- Hvor skal man farme? IKKE NØDVENDIGT
        -- },
        ["coke"] = { -- navn på shell
            obj = `k4coke_shell`, -- object
            door = vector3(-10.462219, -2.492542, -1.063004), -- dør
            pak = vector3(-5.907288, -2.281067, -3.663956), -- pak
            process = vector3(2.099243, 3.317871, -3.663757) -- process
        },
        ["weed"] = {
            obj = `k4weed_shell`,
            door = vector3(-10.965225, -2.581665, -2.487305),
            farm = vector3(-3.923035, -0.466675, -3.663757),
            process = vector3(1.879150, 3.254761, -3.663742),
            pak = vector3(-6.300293, -2.931396, -3.663727)
        },
        ["meth"] = {
            obj = `k4meth_shell`,
            door = vector3(-11.010712, -2.529419, -0.989349),
            process = vector3(-2.081238, -2.103333, -3.213760),
            pak = vector3(1.942505, 3.314453, -3.663849)
        },
    },
    processtid = 2000, -- 1000 = 1 sekund
    farmtid = 1000, -- 1000 = 1 sekund
    packtid = 1000, -- 1000 = 1 sekund
    Notifikationer = {
        Forkertkode = false,
        IkkePoliti = false,
        IkkeBande = false
    }
}