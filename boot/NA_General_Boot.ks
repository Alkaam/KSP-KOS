FUNCTION HAS_FILE {
  PARAMETER name.
  PARAMETER vol.
  SWITCH TO vol.
  LIST FILES IN allFiles.
  FOR file IN allFiles {
    IF file:NAME = name {
      SWITCH TO 1.
      RETURN TRUE.
    }
  }
  SWITCH TO 1.
  RETURN FALSE.
}
