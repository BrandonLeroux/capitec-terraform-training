# Training-specific subnet allocation (kept at the root so the eks module
# stays generic and just receives cidr_blocks).
# Each trainee gets 3 consecutive /24s starting at their base octet:
#   10.0.<base>.0/24, 10.0.<base+1>.0/24, 10.0.<base+2>.0/24
locals {
  participants = {
    amen_moipushi         = { name = "Amen Moipushi", base = 0 }
    isaiah_bopape         = { name = "Isaiah Bopape", base = 3 }
    brandon_le_roux       = { name = "Brandon Le Roux", base = 6 }
    darrol_arendse        = { name = "Darrol Arendse", base = 9 }
    given_mahole          = { name = "Given Mahole", base = 15 }
    gordon_steele         = { name = "Gordon Steele", base = 18 }
    grant_engel           = { name = "Grant Engel", base = 21 }
    graeme_emslie         = { name = "Graeme Emslie", base = 24 }
    balcken_maleboho      = { name = "Balcken Maleboho", base = 27 }
    kgotso_yaso           = { name = "Kgotso Yaso", base = 30 }
    austin_williams       = { name = "Austin Williams", base = 33 }
    jason_govender        = { name = "Jason Govender", base = 36 }
    sherwin_sunker        = { name = "Sherwin Sunker", base = 39 }
    tshepo_mathebula      = { name = "Tshepo Mathebula", base = 42 }
    robert_bristow        = { name = "Robert Bristow", base = 45 }
    taufeeq_sheik         = { name = "Taufeeq Sheik", base = 48 }
    stuart_chalmer        = { name = "Stuart Chalmer", base = 51 }
    suleiman_da_costa     = { name = "Suleiman Da Costa", base = 54 }
    nicholas_van_der_nest = { name = "Nicholas van der Nest", base = 57 }
    nathan_mills          = { name = "Nathan Mills", base = 60 }
    busisiwe_sithole      = { name = "Busisiwe Sithole", base = 63 }
    khayakazi_mqhamane    = { name = "Khayakazi Mqhamane", base = 66 }
    kyle_velera           = { name = "Kyle Velera", base = 69 }
    darryl_irvine         = { name = "Darryl Irvine", base = 72 }
    david_campey          = { name = "David Campey", base = 75 }
    jeff_anderson         = { name = "Jeff Anderson", base = 78 }
    sonique_engelbrecht   = { name = "Sonique Engelbrecht", base = 81 }
    kayla_lee_jansma      = { name = "Kayla-Lee Jansma", base = 84 }
    chanchal_kumar        = { name = "Chanchal Kumar", base = 87 }
    tsepo_mhlongo         = { name = "Tsepo Mhlongo", base = 90 }
    luvuyo_tafeni         = { name = "Luvuyo Tafeni", base = 93 }
    thapelo_seema         = { name = "Thapelo Seema", base = 96 }
    thapelo_seema2        = { name = "Thapelo Seema", base = 99 }
    thapelo_seema3        = { name = "Thapelo Seema", base = 102 }
  }

  subnet_allocation = {
    for key, p in local.participants : key => {
      name    = p.name
      subnets = [for i in range(3) : "10.0.${p.base + i}.0/24"]
    }
  }
}
