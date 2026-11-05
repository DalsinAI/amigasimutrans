/* The FreeType modules Simutrans needs on the Amiga: TrueType (and its
 * sfnt tables), BDF for the fonts Simutrans ships (font/*.bdf), the
 * anti-aliased and mono rasterisers. No autohinter, CFF, Type 1, PCF.
 * The AmiCradle Team. */
FT_USE_MODULE( FT_Driver_ClassRec, tt_driver_class )
FT_USE_MODULE( FT_Driver_ClassRec, bdf_driver_class )
FT_USE_MODULE( FT_Module_Class, psnames_module_class )
FT_USE_MODULE( FT_Module_Class, sfnt_module_class )
FT_USE_MODULE( FT_Renderer_Class, ft_smooth_renderer_class )
FT_USE_MODULE( FT_Renderer_Class, ft_raster1_renderer_class )
