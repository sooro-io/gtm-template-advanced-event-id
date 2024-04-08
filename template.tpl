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
  "displayName": "Advanced Event ID",
  "description": "Generates unique event IDs by combining multiple available data points. You can customize the ID generation approach and the caching behavior. You can also use your own event ID for specific events.",
  "containerContexts": [
    "WEB"
  ],
  "categories": ["UTILITY"]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "GROUP",
    "name": "groupBasics",
    "displayName": "Basics",
    "groupStyle": "ZIPPY_OPEN",
    "subParams": [
      {
        "type": "RADIO",
        "name": "uniquenessElement",
        "displayName": "Uniqueness Element",
        "radioItems": [
          {
            "value": "artificial",
            "displayValue": "Random Number + Timestamp",
            "subParams": [
              {
                "type": "RADIO",
                "name": "cachingBehavior",
                "displayName": "Caching Behavior",
                "radioItems": [
                  {
                    "value": "none",
                    "displayValue": "no caching",
                    "help": "A new uniqueness element is generated for each individual event."
                  },
                  {
                    "value": "temporary",
                    "displayValue": "temporary",
                    "help": "The uniqueness element is temporarily cached in the window object of the browser. It gets deleted as soon the tab or browser will be closed.\n\u003cbr /\u003e\u003cbr /\u003e\nThe used variable name in the window object of the browser is \u003cb\u003egtmClientId\u003c/b\u003e."
                  },
                  {
                    "value": "persistant",
                    "displayValue": "persistant",
                    "help": "The uniqueness element is cached in the localStorage of the browser. The value therefore remains the same across several sessions and even across tabs in the users\u0027 browser.\n\u003cbr /\u003e\u003cbr /\u003e\nThe entry in localStorage uses the key \u003cb\u003egtmClientId\u003c/b\u003e.\n\u003cbr /\u003e\u003cbr /\u003e\n\u003ci\u003eWhen using this option, it may be necessary to adjust the information in your consent banner and/or privacy policy to comply with legal requirements.\u003c/i\u003e"
                  }
                ],
                "simpleValueType": true,
                "defaultValue": "session"
              }
            ]
          },
          {
            "value": "clientId",
            "displayValue": "Client ID",
            "subParams": [
              {
                "type": "SELECT",
                "name": "clientId",
                "displayName": "",
                "macrosInSelect": true,
                "selectItems": [],
                "simpleValueType": true,
                "alwaysInSummary": true
              }
            ],
            "help": ""
          }
        ],
        "simpleValueType": true,
        "help": "Multiple available data points are concatenated to create an event ID. However, to ensure the uniqueness of this ID, an additional element is required that is ideally very consistent and unique.\n\u003cbr /\u003e\u003cbr /\u003e\nIt is therefore best to use a client ID or a value with similar characteristics.",
        "defaultValue": "artificial",
        "subParams": []
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "groupOverrideRules",
    "displayName": "Override Rules",
    "groupStyle": "ZIPPY_OPEN",
    "subParams": [
      {
        "type": "CHECKBOX",
        "name": "useTransactionId",
        "checkboxText": "use transaction ID of purchase event",
        "simpleValueType": true,
        "displayName": "GA4 events",
        "help": "When a \u003cb\u003epurchase\u003c/b\u003e event is triggered, the value of \u003cb\u003eecommerce.transaction_id\u003c/b\u003e will be used as event ID.",
        "alwaysInSummary": true
      },
      {
        "type": "SIMPLE_TABLE",
        "name": "overrideEventIds",
        "simpleTableColumns": [
          {
            "defaultValue": "",
            "displayName": "Event Name",
            "name": "eventName",
            "type": "TEXT",
            "isUnique": true
          },
          {
            "defaultValue": "",
            "displayName": "ID",
            "name": "id",
            "type": "TEXT",
            "selectItems": []
          }
        ],
        "help": "Use an existing ID as the event ID for certain events.\n\u003cbr /\u003e\u003cbr /\u003e\nFor example, unique IDs are often available for user registration or lead events.",
        "displayName": "Special IDs",
        "alwaysInSummary": true
      }
    ]
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

var copyFromDataLayer = require('copyFromDataLayer');
var copyFromWindow = require('copyFromWindow');
var generateRandom = require('generateRandom');
var getTimestampMillis = require('getTimestampMillis');
var localStorage = require('localStorage');
var makeInteger = require('makeInteger');
var setInWindow = require('setInWindow');

var eventName = copyFromDataLayer('event');

// use transaction ID as event ID if feature is enabled
if (data.useTransactionId && eventName === 'purchase') {
  var transactionId = copyFromDataLayer('ecommerce.transaction_id');

  if (transactionId) {
    return transactionId;
  }
}

// use custom event ID for defined events
var overrideEventIds = data.overrideEventIds || [];

for (var i = 0; i < overrideEventIds.length; i++) {
  if (eventName === overrideEventIds[i].eventName && overrideEventIds[i].id) {
    return overrideEventIds[i].id;
  }
}

// event ID generation
// step 1: define client ID (first part of event ID)
var clientId;

var generateClientId = () => {
  return (generateRandom(0, 999999999) * getTimestampMillis()).toString(36).substring(0, 11);
};

if (data.uniquenessElement === 'clientId') {
  clientId = data.clientId || generateClientId();
} else {
  var cachedClientId = copyFromWindow('gtmClientId') || localStorage.getItem('gtmClientId');
  
  clientId = cachedClientId || generateClientId();
  
  if (data.cachingBehavior === 'temporary' && !cachedClientId) {
    setInWindow('gtmClientId', clientId);
  } else if (data.cachingBehavior === 'persistant' && !cachedClientId) {
    localStorage.setItem('gtmClientId', clientId);
  }
}

// step 2: define init time (second part of event ID)
var initTime = copyFromDataLayer('gtm.start') || copyFromWindow('gtmPageLoadId') || generateRandom(0, 999999999);

// step 3: create artifical event ID
return clientId + '_' + initTime + '_' + copyFromDataLayer('gtm.uniqueEventId');


___WEB_PERMISSIONS___

[
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
                    "string": "gtmClientId"
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
        "publicId": "read_data_layer",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedKeys",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "keyPatterns",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "gtm.start"
              },
              {
                "type": 1,
                "string": "gtm.uniqueEventId"
              },
              {
                "type": 1,
                "string": "event"
              },
              {
                "type": 1,
                "string": "ecommerce.transaction_id"
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
        "publicId": "access_globals",
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
                  },
                  {
                    "type": 1,
                    "string": "execute"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "gtmPageLoadId"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
                  },
                  {
                    "type": 8,
                    "boolean": false
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
                  },
                  {
                    "type": 1,
                    "string": "execute"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "gtmClientId"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
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

scenarios:
- name: use the artificially generated ID
  code: |-
    const mockData = {
      element: 'artificial',
    };

    let variableResult = runCode(mockData);

    assertThat(variableResult).contains('_1670242881982_25').hasLength(28);
- name: use the specified client ID
  code: |-
    const mockData = {
      uniquenessElement: 'clientId',
      clientId: 'custom',
    };

    let variableResult = runCode(mockData);

    assertThat(variableResult).isEqualTo('custom_1670242881982_25');
- name: use fallback if the specified client ID is undefined
  code: |-
    const mockData = {
      uniquenessElement: 'clientId',
      clientId: undefined,
    };

    let variableResult = runCode(mockData);

    assertThat(variableResult)
      .doesNotContain('undefined')
      .hasLength(28);
- name: use GA4 transaction ID
  code: |-
    const mockData = {
      useTransactionId: true,
    };

    let variableResult = runCode(mockData);

    assertThat(variableResult).isEqualTo('12345');
- name: use provided ID for specific event
  code: |-
    const mockData = {
      overrideEventIds: [
        {
          eventName: 'purchase',
          id: 'overwritten-id'
        }
      ]
    };

    let variableResult = runCode(mockData);

    assertThat(variableResult).isEqualTo('overwritten-id');
- name: use fallback if provided ID for specific event is undefined
  code: |-
    const mockData = {
      overrideEventIds: [
        {
          eventName: 'purchase',
          id: undefined
        }
      ]
    };

    let variableResult = runCode(mockData);

    assertThat(variableResult)
      .doesNotContain('undefined')
      .hasLength(28);
setup: "mock('copyFromDataLayer', key => {\n  const dataLayer = {\n    'gtm.start':\
  \ '1670242881982',\n    'gtm.uniqueEventId': '25',\n    'ecommerce.transaction_id':\
  \ '12345',\n    'event': 'purchase',\n  };\n  \n  return dataLayer[key];\n});"


___NOTES___

Created on 8.4.2024, 14:48:44


