#' Turns overlay images transparent based on altitude. Can be used to create an
#' image overlay that will only apply to valleys, or only to hills.
#'
#' @param overlay_image the image on which to alter transparency
#' @param altitude_raster altitude raster file that will be used to adjust transparency
#' @param alpha_max Transparency required at higher altitudes
#' @param alpha_min Transparency required at lower altitudes
#' @param pct_alt_low The percent of maximum altitude contained in altitude_raster
#' at which alpha_max will apply
#' @param pct_alt_high The percent of maximum altitude contained in altitude_raster
#' at which alpha_min will apply
#'
#' @return An image with transparency defined by altitude
#'
#' @examples
#' # altitude_transparency defaults to making hills transparent.  Flip alpha_max
#' # and alpha_min values to reverse it.
#' #
#' # Transparency in the range between pct_alt_low and pct_alt_high will
#' # smoothly transition between alpha_max and alpha_min.
#'
#' overlay_image <- elevation_shade(example_raster, elevation_palette = c("#000000", "#FF0000"))
#'
#' #Making hills transparent
#'
#' ggmap_overlay_transparent_hills <- altitude_transparency(overlay_image,
#'    example_raster, alpha_max = 0.8, alpha_min = 0, pct_alt_low = 0.05,
#'    pct_alt_high = 0.25)
#'
#' # To make valleys transparent, flip alpha_max and alpha_min
#' ggmap_overlay_transparent_valleys <- altitude_transparency(overlay_image,
#'    example_raster, alpha_max = 0, alpha_min = 0.8, pct_alt_low = 0.05,
#'    pct_alt_high = 0.25)
#' @export
altitude_transparency <- function(overlay_image, altitude_raster, alpha_max = 0.4, alpha_min = 0, pct_alt_low = 0.05, pct_alt_high = 0.25){

  if (pct_alt_high == pct_alt_low){
    stop("pct_alt_high must be > pct_alt_low")
  }

  pct_max_height <- (raster::as.array(altitude_raster) - min(raster::as.array(altitude_raster))) / (max(raster::as.array(altitude_raster)) - min(raster::as.array(altitude_raster)))

  pct_max_height_alpha <- pct_max_height

  pct_max_height_alpha[pct_max_height[] < pct_alt_low] <- alpha_max

  pct_max_height_alpha[pct_max_height[] > pct_alt_high] <- alpha_min

  if(alpha_min < alpha_max){
    pct_max_height_alpha[pct_max_height <= pct_alt_high &
                           pct_max_height >= pct_alt_low] <-
      (1 - (pct_max_height[pct_max_height[] <= pct_alt_high &
                             pct_max_height[] >= pct_alt_low] - pct_alt_low) / (pct_alt_high - pct_alt_low)) * alpha_max
  } else {
    pct_max_height_alpha[pct_max_height <= pct_alt_high &
                           pct_max_height >= pct_alt_low] <-
      ((pct_max_height[pct_max_height[] <= pct_alt_high &
                         pct_max_height[] >= pct_alt_low] - pct_alt_low) / (pct_alt_high - pct_alt_low)) * alpha_min
  }

  overlay_image[,,4] <- pct_max_height_alpha

  overlay_image
}
