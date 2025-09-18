class CountryFlags {
  static const Map<String, String> countryCodeToFlag = {
    'GH': '🇬🇭', // Ghana
    'US': '🇺🇸', // United States
    'GB': '🇬🇧', // United Kingdom
    'CA': '🇨🇦', // Canada
    'AU': '🇦🇺', // Australia
    'DE': '🇩🇪', // Germany
    'FR': '🇫🇷', // France
    'IT': '🇮🇹', // Italy
    'ES': '🇪🇸', // Spain
    'NL': '🇳🇱', // Netherlands
    'BE': '🇧🇪', // Belgium
    'CH': '🇨🇭', // Switzerland
    'AT': '🇦🇹', // Austria
    'SE': '🇸🇪', // Sweden
    'NO': '🇳🇴', // Norway
    'DK': '🇩🇰', // Denmark
    'FI': '🇫🇮', // Finland
    'IE': '🇮🇪', // Ireland
    'PT': '🇵🇹', // Portugal
    'GR': '🇬🇷', // Greece
    'PL': '🇵🇱', // Poland
    'CZ': '🇨🇿', // Czech Republic
    'HU': '🇭🇺', // Hungary
    'RO': '🇷🇴', // Romania
    'BG': '🇧🇬', // Bulgaria
    'HR': '🇭🇷', // Croatia
    'SI': '🇸🇮', // Slovenia
    'SK': '🇸🇰', // Slovakia
    'LT': '🇱🇹', // Lithuania
    'LV': '🇱🇻', // Latvia
    'EE': '🇪🇪', // Estonia
    'CY': '🇨🇾', // Cyprus
    'LU': '🇱🇺', // Luxembourg
    'MT': '🇲🇹', // Malta
    'IS': '🇮🇸', // Iceland
    'LI': '🇱🇮', // Liechtenstein
    'MC': '🇲🇨', // Monaco
    'SM': '🇸🇲', // San Marino
    'VA': '🇻🇦', // Vatican City
    'AD': '🇦🇩', // Andorra
    'NZ': '🇳🇿', // New Zealand
    'JP': '🇯🇵', // Japan
    'KR': '🇰🇷', // South Korea
    'CN': '🇨🇳', // China
    'IN': '🇮🇳', // India
    'BR': '🇧🇷', // Brazil
    'MX': '🇲🇽', // Mexico
    'AR': '🇦🇷', // Argentina
    'CL': '🇨🇱', // Chile
    'CO': '🇨🇴', // Colombia
    'PE': '🇵🇪', // Peru
    'VE': '🇻🇪', // Venezuela
    'EC': '🇪🇨', // Ecuador
    'BO': '🇧🇴', // Bolivia
    'PY': '🇵🇾', // Paraguay
    'UY': '🇺🇾', // Uruguay
    'GY': '🇬🇾', // Guyana
    'SR': '🇸🇷', // Suriname
    'FK': '🇫🇰', // Falkland Islands
    'GF': '🇬🇫', // French Guiana
    'ZA': '🇿🇦', // South Africa
    'EG': '🇪🇬', // Egypt
    'NG': '🇳🇬', // Nigeria
    'KE': '🇰🇪', // Kenya
    'UG': '🇺🇬', // Uganda
    'TZ': '🇹🇿', // Tanzania
    'ET': '🇪🇹', // Ethiopia
    'SD': '🇸🇩', // Sudan
    'DZ': '🇩🇿', // Algeria
    'MA': '🇲🇦', // Morocco
    'TN': '🇹🇳', // Tunisia
    'LY': '🇱🇾', // Libya
    'CM': '🇨🇲', // Cameroon
    'CI': '🇨🇮', // Ivory Coast
    'BF': '🇧🇫', // Burkina Faso
    'ML': '🇲🇱', // Mali
    'NE': '🇳🇪', // Niger
    'TD': '🇹🇩', // Chad
    'CF': '🇨🇫', // Central African Republic
    'CG': '🇨🇬', // Republic of the Congo
    'CD': '🇨🇩', // Democratic Republic of the Congo
    'GA': '🇬🇦', // Gabon
    'GQ': '🇬🇶', // Equatorial Guinea
    'ST': '🇸🇹', // Sao Tome and Principe
    'AO': '🇦🇴', // Angola
    'ZM': '🇿🇲', // Zambia
    'ZW': '🇿🇼', // Zimbabwe
    'BW': '🇧🇼', // Botswana
    'NA': '🇳🇦', // Namibia
    'SZ': '🇸🇿', // Eswatini
    'LS': '🇱🇸', // Lesotho
    'MG': '🇲🇬', // Madagascar
    'MU': '🇲🇺', // Mauritius
    'SC': '🇸🇨', // Seychelles
    'KM': '🇰🇲', // Comoros
    'DJ': '🇩🇯', // Djibouti
    'SO': '🇸🇴', // Somalia
    'ER': '🇪🇷', // Eritrea
    'SS': '🇸🇸', // South Sudan
    'RW': '🇷🇼', // Rwanda
    'BI': '🇧🇮', // Burundi
    'MW': '🇲🇼', // Malawi
    'MZ': '🇲🇿', // Mozambique
  };

  static String getFlagEmoji(String countryCode) {
    return countryCodeToFlag[countryCode.toUpperCase()] ??
        '🇺🇳'; // Default to UN flag
  }
}
