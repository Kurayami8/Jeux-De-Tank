-- Débogueur Visual Studio Code tomblind.local-lua-debugger-vscode
if pcall(require, "lldebugger") then
    require("lldebugger").start()
end

function math.dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end
math.randomseed(os.time())

--Tab Hero
local hero = {}
hero.x = 1
hero.y = 1
hero.direction = "up"
hero.rotation = 0
hero.vitesse = 85

--Tab tir Hero
local lstTirs = {}

--Tab tank ennemi
local lstEnnemis = {}
local timer = 0
local frequenceEnnemi = 15

local score = 0
--Taille de la fenetre
love.window.setMode(1024, 768)

--Largeur et la hauteur de l'écran
largeur = love.graphics.getWidth()
hauteur = love.graphics.getHeight()

--Liste pour mettre images du sol de la Map
local imageMap = {}
--Variables pour largeur et hauteur de la Map
local MAP_LARGEUR = 32
local MAP_HAUTEUR = 24
-- Variables pour largeur et hauteur des tiles
local TILE_LARGEUR = 32
local TILE_HAUTEUR = 32
--Table pour stocker la Map
local map = {}

--Cree la Map et rempli aléatoirement le sol de tiles
function CreeMap()
    for ligne = 1, MAP_HAUTEUR do
        map[ligne] = {}
        for colonne = 1, MAP_LARGEUR do
            map[ligne][colonne] = love.math.random(1, 2)
        end
    end
end

--[[function timerEnnemis()
    for timer=0,20 do
        print(timer)
    end
end]]

function CreeEnnemis()
    print("Spawn un tank")
    local ennemi = {}
    --ennemi.x = 100
    --ennemi.y = 100
    ennemi.x = math.random(10, largeur)
    ennemi.y = math.random(10, hauteur)
    ennemi.etat = "right"
    ennemi.dureeEtat = math.random(1, 2)
    ennemi.rotation = 0
    ennemi.vitesse = math.random(60, 120)
    table.insert(lstEnnemis, ennemi)

    --ennemi.x = math.random(10, largeur-10)
    --ennemi.y = math.random(10, hauteur-10)
end
--=============================================================================================
--|                                    LOVE.LOAD                                              |
--=============================================================================================

function love.load()
    --Tiles pour sol Map
    imageMap[1] = love.graphics.newImage("images/Herbe.png")
    imageMap[2] = love.graphics.newImage("images/Terre.png")
    imageMap[3] = love.graphics.newImage("images/Sable.png")

    --Charger la map
    CreeMap()

    --Afficher image Hero
    hero.image = love.graphics.newImage("images/tank_hero.png")
    --Avoir largeur et hauteur de l'image
    largeurHero = hero.image:getWidth()
    hauteurHero = hero.image:getHeight()
    --Afficher image tir Hero
    imageTir = love.graphics.newImage("images/bulletHero.png")
    largeurTirHero = imageTir:getWidth()
    hauteurTirHero = imageTir:getHeight()
    
    --Afficher image Ennemi
    imageEnnemi = love.graphics.newImage("images/tank_ennemi.png")
    --Avoir largeur et hauteur de l'image Ennemi
    largeurEnnemi = imageEnnemi:getWidth()
    hauteurEnnemi = imageEnnemi:getHeight()
    --Afficher image tir Ennemi
    imageTirEnnemi = love.graphics.newImage("images/bulletEnnemi.png")
    largeurTirEnnemi = imageTirEnnemi:getWidth()
    hauteurTirEnnemi = imageTirEnnemi:getHeight()

    CreeEnnemis()
end

--=============================================================================================
--|                                    LOVE.UPDATE                                            |
--=============================================================================================

function love.update(dt)
    --Faire tourner le tank vers la droite
    if love.keyboard.isDown("d") then
        hero.rotation = hero.rotation + 2 * dt
    end

    --Faire tourner le tank vers la gauche
    if love.keyboard.isDown("q") then
        hero.rotation = hero.rotation - 2 * dt
    end

    --Faire avancer le tank
    if love.keyboard.isDown("z") then
        local ouIlVaEnX = hero.x + (hero.vitesse * math.cos(hero.rotation)) * dt
        local ouIlVaEnY = hero.y + (hero.vitesse * math.sin(hero.rotation)) * dt
        if ouIlVaEnX > 0 and ouIlVaEnY > 0 and ouIlVaEnX < largeur and ouIlVaEnY < hauteur then
            hero.x = ouIlVaEnX
            hero.y = ouIlVaEnY
        end
    end

    --Faire les tirs
    --Et effacer les tirs si ils sortent de la fenêtre
    for n = #lstTirs, 1, -1 do
        local tir = lstTirs[n]
        tir.x = tir.x + tir.vitesse * math.cos(tir.rotation) * dt
        tir.y = tir.y + tir.vitesse * math.sin(tir.rotation) * dt
        tir.supprime = false
        -- Vérifier si le tir est sorti de l'écran, et si oui, le supprimer de la liste
        if tir.x < 0 or tir.y < 0 or tir.x > largeur or tir.y > hauteur then
            table.remove(lstTirs, n)
        end

        -- Mettre une portée aux tirs
        tir.distance = tir.distance + tir.vitesse * dt
        if tir.distance > 200 then
            table.remove(lstTirs, n)
        end

        -- Calculer distance collision tir Hero et Tank Ennemi
        -- Effacer Tank Ennemi quand tir Hero touche Ennemi
        -- Et effacer tir quand il à toucher le Tank Ennemi
        -- Crée un score quand le Hero à tuer un Tank Ennemi
        for e = #lstEnnemis, 1, -1 do
            local ennemi = lstEnnemis[e]
            if math.dist(ennemi.x, ennemi.y, tir.x, tir.y) < (largeurEnnemi/2 + hauteurEnnemi/2)/2 then
                print("collision")
                table.remove(lstEnnemis, e)
                table.remove(lstTirs, n)
                score = score + 1
            end
        end
    end

    --timerEnnemis()
    timer = timer + dt
    if timer >= frequenceEnnemi then
        timer = 0
        CreeEnnemis()
    end

    --Pour faire spawn les enne
    for _, ennemi in ipairs(lstEnnemis) do
        ennemi.x = ennemi.x + ennemi.vitesse*dt
        if ennemi.x < 0 or ennemi.x > largeur then
            ennemi.rotation = ennemi.rotation + math.rad(90*2)
            ennemi.vitesse = - ennemi.vitesse
        end
    end

end
--=============================================================================================
--|                                    LOVE.DRAW                                              |
--=============================================================================================

function love.draw()
    --Dessiner la Map
    for ligne = 1, MAP_HAUTEUR do
        for colonne = 1, MAP_LARGEUR do
            local id = map[ligne][colonne]
            local texture = imageMap[id]
            if texture ~= nil then
                love.graphics.draw(texture, (colonne - 1) * TILE_LARGEUR, (ligne - 1) * TILE_HAUTEUR)
            end
        end
    end

    --Afficher les tirs
    for _, v in ipairs(lstTirs) do
        love.graphics.draw(imageTir, v.x, v.y, v.rotation, 1, 1, largeurTirHero / 2, hauteurTirHero / 2)
    end

    --Afficher le hero
    love.graphics.draw(hero.image, hero.x, hero.y, hero.rotation, 1, 1, largeurHero / 2, hauteurHero / 2)

    --Afficher le nombre de tirs
    love.graphics.print("Nb de tirs: " .. #lstTirs, 1, 1)

  --Afficher les ennemis
  for _, e in ipairs(lstEnnemis) do
    love.graphics.draw(imageEnnemi, e.x, e.y, e.rotation, 1, 1, largeurEnnemi / 2, hauteurEnnemi / 2)
  end

  love.graphics.print("Score: " .. score, 300, 1)

end

--=============================================================================================
--|                                    LOVE.KEYPRESSED                                        |
--=============================================================================================

function love.keypressed(key)
    --Tirer quand tu appuis sur espace
    if key == "space" then
        print(hero.rotation)
        local tir = {}
        tir.x = hero.x
        tir.y = hero.y
        tir.rotation = hero.rotation
        tir.distance = 0
        tir.vitesse = 100
        table.insert(lstTirs, tir)
    end
end