___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "OM - GA4 - Get Client ID \u0026 Session Data",
  "categories": [
    "UTILITY",
    "ANALYTICS"
  ],
  "description": "Uses the readAnalyticsStorage API to safely obtain GA4 Client ID or session data (Session ID / Session Number). Session retrieval requires a valid Measurement ID.",
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "RADIO",
    "name": "id",
    "label": "Select the type of data you want to retrieve",
    "simpleValueType": true,
    "default": "client_id",
    "radioItems": [
      {
        "value": "client_id",
        "displayValue": "Client ID"
      },
      {
        "value": "session_data",
        "displayValue": "Session Data"
      }
    ],
    "displayName": ""
  },
  {
    "type": "GROUP",
    "name": "session_group",
    "displayName": "Session Configuration",
    "groupStyle": "NO_ZIPPY",
    "subParams": [
      {
        "type": "TEXT",
        "name": "measurement_id",
        "displayName": "GA4 Measurement ID",
        "label": "Measurement ID (e.g., G-XXXXXXX)",
        "help": "Required when returning session information. Must start with \u0027G-\u0027.",
        "default": "",
        "simpleValueType": true,
        "valueValidators": [
          {
            "type": "REGEX",
            "args": [
              "^G-[A-Z0-9]+$"
            ],
            "errorMessage": "The Measurement ID must start with \u0027G-\u0027 (e.g., G-ABC123DEF4)."
          },
          {
            "type": "NON_EMPTY"
          }
        ]
      },
      {
        "type": "RADIO",
        "name": "session_data_type",
        "displayName": "Session Field",
        "label": "Select which session value to return",
        "simpleValueType": true,
        "default": "session_id",
        "radioItems": [
          {
            "value": "session_id",
            "displayValue": "Session ID"
          },
          {
            "value": "session_number",
            "displayValue": "Session Number"
          }
        ]
      }
    ],
    "enablingConditions": [
      {
        "paramName": "id",
        "paramValue": "session_data",
        "type": "EQUALS"
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "storage_group",
    "displayName": "Store Data",
    "groupStyle": "NO_ZIPPY",
    "subParams": [
      {
        "type": "CHECKBOX",
        "name": "saveinLocalStorage",
        "checkboxText": "Save Data in Local Storage",
        "simpleValueType": true,
        "help": "Saved as \"GA_data_field_name\"."
      },
      {
        "type": "CHECKBOX",
        "name": "saveasCookie",
        "checkboxText": "Save Data in a Cookie",
        "simpleValueType": true,
        "help": "Saved as \"GA_data_field_name\"."
      }
    ]
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

const readAnalyticsStorage = require('readAnalyticsStorage');
const localStorage = require('localStorage');
const setCookie = require('setCookie');
const log = require('logToConsole');
const makeString = require('makeString');

log('🚀 Script démarré - Début de l\'exécution');

const sourceId = data.id;
const saveInLocalStorage = data.saveinLocalStorage;
const saveAsCookie = data.saveasCookie;

log('📊 Configuration reçue:');
log('  sourceId:', sourceId);
log('  saveInLocalStorage:', saveInLocalStorage);
log('  saveAsCookie:', saveAsCookie);
log('  measurement_id:', data.measurement_id || 'non défini');
log('  session_data_type:', data.session_data_type || 'non défini');

// Nom pour le stockage (clé)
const storageKey = "GA_data_";
log('🔑 Clé de stockage:', storageKey);

// Variable pour stocker la valeur finale
let finalValue;

// Options de cookie
const cookieOptions = {
  domain: 'auto',
  path: '/',
  secure: true,
  samesite: 'Lax'
};
log('🍪 Options de cookie configurées');

// Charger les infos depuis le stockage Analytics
log('📈 Tentative de lecture du stockage Analytics...');
const analyticsData = readAnalyticsStorage();
log('📈 Données Analytics récupérées:', analyticsData);

// Vérification de la structure des données
if (!analyticsData) {
  log('❌ ERREUR: analyticsData est null ou undefined');
  return undefined;
}

if (typeof analyticsData !== 'object') {
  log('❌ ERREUR: analyticsData n\'est pas un objet. Type:', typeof analyticsData);
  return undefined;
}

log('✅ analyticsData est valide. Type:', typeof analyticsData);

// Cas client_id
if (sourceId === 'client_id') {
  log('🎯 Traitement du cas client_id');
  
  finalValue = analyticsData.client_id;
  log('🆔 Client ID trouvé:', finalValue);
  
  if (!finalValue) {
    log('⚠️ WARNING: client_id est vide, null ou undefined');
  }
  
  if (finalValue) {
    const valueToStore = makeString(finalValue);
    log('🔄 Valeur convertie en string:', valueToStore);
    
    if (saveInLocalStorage) {
      log('💾 Tentative de sauvegarde en localStorage...');
      const success = localStorage.setItem(storageKey + "client_id", valueToStore);
      log('💾 Résultat localStorage:', success);
    }
    
    if (saveAsCookie) {
      log('🍪 Tentative de sauvegarde en cookie...');
      setCookie(storageKey + "client_id", valueToStore, cookieOptions, false);
      log('🍪 Cookie défini');
    }
  }
}

// Cas session_data
if (sourceId === 'session_data') {
  log('🎯 Traitement du cas session_data');
  
  const mId = data.measurement_id;
  const sType = data.session_data_type;
  
  log('📊 Paramètres session:');
  log('  measurement_id:', mId);
  log('  session_data_type:', sType);
  
  if (!mId) {
    log('❌ ERREUR: measurement_id manquant');
    return undefined;
  }
  
  if (!sType) {
    log('❌ ERREUR: session_data_type manquant');
    return undefined;
  }
  
  // Vérification de la présence des sessions
  if (!analyticsData.sessions) {
    log('❌ ERREUR: Pas de propriété "sessions" dans analyticsData');
    return undefined;
  }
  
  if (!(analyticsData.sessions && analyticsData.sessions.length >= 0)) {
    log('❌ ERREUR: sessions n\'est pas un tableau valide. Type:', typeof analyticsData.sessions);
    return undefined;
  }
  
  log('📊 Nombre de sessions disponibles:', analyticsData.sessions.length);
  log('📊 Sessions disponibles:', analyticsData.sessions);
  
  // Recherche d'une session correspondant au Measurement ID
  let sessionFound = false;
  
  for (let i = 0; i < analyticsData.sessions.length; i++) {
    const s = analyticsData.sessions[i];
    log('🔍 Examen session ' + i + ':', s);
    
    if (s.measurement_id === mId) {
      log('✅ Session correspondante trouvée:', s);
      sessionFound = true;
      
      if (sType === 'session_id') {
        log('🎯 Récupération du session_id');
        finalValue = s.session_id;
        log('🆔 Session ID trouvé:', finalValue);
        
        if (finalValue) {
          const valueToStore = makeString(finalValue);
          log('🔄 Valeur convertie en string:', valueToStore);
          
          if (saveInLocalStorage) {
            log('💾 Tentative de sauvegarde session_id en localStorage...');
            const success = localStorage.setItem(storageKey + "session_id", valueToStore);
            log('💾 Résultat localStorage:', success);
          }
          
          if (saveAsCookie) {
            log('🍪 Tentative de sauvegarde session_id en cookie...');
            setCookie(storageKey + "session_id", valueToStore, cookieOptions, false);
            log('🍪 Cookie session_id défini');
          }
        } else {
          log('⚠️ WARNING: session_id est vide dans la session trouvée');
        }
        break;
      }
      
      if (sType === 'session_number') {
        log('🎯 Récupération du session_number');
        finalValue = s.session_number;
        log('🔢 Session Number trouvé:', finalValue);
        
        if (finalValue) {
          const valueToStore = makeString(finalValue);
          log('🔄 Valeur convertie en string:', valueToStore);
          
          if (saveInLocalStorage) {
            log('💾 Tentative de sauvegarde session_number en localStorage...');
            const success = localStorage.setItem(storageKey + "session_number", valueToStore);
            log('💾 Résultat localStorage:', success);
          }
          
          if (saveAsCookie) {
            log('🍪 Tentative de sauvegarde session_number en cookie...');
            setCookie(storageKey + "session_number", valueToStore, cookieOptions, false);
            log('🍪 Cookie session_number défini');
          }
        } else {
          log('⚠️ WARNING: session_number est vide dans la session trouvée');
        }
        break;
      }
    } else {
      log('❌ Session ' + i + ' ne correspond pas. measurement_id attendu: ' + mId + ', trouvé: ' + s.measurement_id);
    }
  }
  
  if (!sessionFound) {
    log('❌ ERREUR: Aucune session trouvée avec le measurement_id:', mId);
    log('📊 Vérifiez les measurement_ids dans vos sessions');
  }
}

log('🎯 Valeur finale à retourner:', finalValue);
log('✅ Script terminé');

return finalValue;


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "read_analytics_storage",
        "versionId": "1"
      },
      "param": []
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "access_local_storage",
        "versionId": "1"
      },
      "param": [
        {
          "key": "keys",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "key"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "GA_data_session_number"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": true
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "key"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "GA_data_session_id"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": true
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "key"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "GA_data_client_id"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": true
                  }
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "set_cookies",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedCookies",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "name"
                  },
                  {
                    "type": 1,
                    "string": "domain"
                  },
                  {
                    "type": 1,
                    "string": "path"
                  },
                  {
                    "type": 1,
                    "string": "secure"
                  },
                  {
                    "type": 1,
                    "string": "session"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "GA_data_client_id"
                  },
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "any"
                  },
                  {
                    "type": 1,
                    "string": "any"
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "name"
                  },
                  {
                    "type": 1,
                    "string": "domain"
                  },
                  {
                    "type": 1,
                    "string": "path"
                  },
                  {
                    "type": 1,
                    "string": "secure"
                  },
                  {
                    "type": 1,
                    "string": "session"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "GA_data_session_id"
                  },
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "any"
                  },
                  {
                    "type": 1,
                    "string": "any"
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "name"
                  },
                  {
                    "type": 1,
                    "string": "domain"
                  },
                  {
                    "type": 1,
                    "string": "path"
                  },
                  {
                    "type": 1,
                    "string": "secure"
                  },
                  {
                    "type": 1,
                    "string": "session"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "GA_data_session_number"
                  },
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "any"
                  },
                  {
                    "type": 1,
                    "string": "any"
                  }
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios: []


___NOTES___

Created on 03/09/2025, 16:39:46


