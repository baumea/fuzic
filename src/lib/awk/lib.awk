# Awk methods commonly used

# Escape string
function escape(s) {
  gsub("&", "\\\\&", s)
  return s
}
