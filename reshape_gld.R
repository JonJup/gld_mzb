# ---------------------------- #
### --- reshape gld data --- ### 
# ---------------------------- #

# date written: 07.10.20
# date changed:
# date used   : 07.10.20


# setup -------------------------------------------------------------------
pacman::p_load(data.table, magrittr, sf, tmap)

# load data ---------------------------------------------------------------
bio <- fread("../Fliess_Makrozoobenthos_Taxa.csv")
env <- fread("../data.csv")
bio2 <- fread("~/01_Uni/02_getreal/002_working_package_02/001_community_data/001_individual_data_sets/001_ld/001_raw_data/mzb_samples.csv")
env2 <- fread("~/01_Uni/02_getreal/002_working_package_02/001_community_data/001_individual_data_sets/001_ld/001_raw_data/mzb_sites.csv")

# reshaping ---------------------------------------------------------------
bio[, c(
        "date",
        "sample_id",
        "site_id",
        "taxon",
        "ind_qm",
        "abclass",
        "source",
        "aqem_id",
        "taxon_aqem",
        "ind_from_class",
        "class_from_ind",
        "annot",
        "comment_clean",
        "comment_other"
) := .(
        as.IDate(Datum, format = "%d.%m.%Y"),
        Probe_Nr,
        Mst_Nr_Bio,
        Taxon,
        IZ,
        HK,
        "GLD",
        NA,
        NA,
        NA,
        NA,
        NA,
        NA,
        NA
)]
env[, c(
        "state",
        "site_id",
        "site_nr",
        "site_name",
        "easting",
        "northing",
        "stream",
        "type",
        "comment",
        "geom"
) := .("Saxony-Anhalt",
       Mst_Nr_Bio,
       NA,
       Messstelle,
       RW,
       HW,
       Gewaesser,
       Typ_LAWA ,
       NA,
       NA)]


# new data set 
bio_new <- bio[,names(bio2), with=F]
env_new <- env[,names(env2), with=F]
env_new[, site_nr := as.character(site_nr)]
# make spatial 
st_env_new <- st_as_sf(env_new, coords=c("easting", "northing"))
st_crs(st_env_new) <- 32632 # WGS 84 / UTM zone 32N
# tmap_mode("view")
# tm_shape(st_env_new) + tm_dots()

# transform to same CRS as other data (DHDN / 3-degree Gauss zone 3, EPSG: 31463)
st_env_new %<>% st_transform(crs=31463)

# add new coordinates to data
env_new[,c("easting", "northing", "geom") := .(st_coordinates(st_env_new)[,1],
                                       st_coordinates(st_env_new)[,2], 
                                       st_as_binary(st_env_new$geometry, EWKB=T, hex=T))]
saveRDS(bio_new, "gld_bio_data.RDS")
saveRDS(env_new, "gld_site_data.RDS")
