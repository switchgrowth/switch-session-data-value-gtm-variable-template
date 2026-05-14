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
  "displayName": "Switch - Session Data Value",
  "description": "Provides the ability to retrieve a value from a Switch Session Data cookie.",
  "categories": ["SESSION_RECORDING"],
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "cookieName",
    "displayName": "Cookie Name",
    "simpleValueType": true,
    "help": "Case insensitive - A unique name that this cookie will be stored under. Either \"Switch\" or the organizations name \"Google\".",
    "defaultValue": "SwitchTempData",
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

const log = require('logToConsole');
const getCookieValues = require('getCookieValues');
const fromBase64 = require('fromBase64');
const JSON = require('JSON');

// Get user-provided data from the template fields
const cookieName = "__Secure-" + (data.cookieName || 'SwitchTempData');

// Check 1: Get the cookie and ensure it's not null or empty.
const cookieValuesArr = getCookieValues(cookieName);
if (!cookieValuesArr || cookieValuesArr.length === 0) {
  // Silent return if empty to prevent console clutter on every page load
  return undefined;
}

// Check 2: Decode the cookie and ensure the result is not empty.
const decodedCookie = fromBase64(cookieValuesArr.toString());
if (!decodedCookie) {
  log('Switch Session Data: Decoded cookie "' + cookieName + '" is empty.');
  return undefined;
}

// Check 3: Prevent JSON.parse errors by checking if it looks like an object.
if (decodedCookie.trim().indexOf('{') !== 0) {
  log('Switch Session Data: Decoded cookie value is not a valid JSON object.');
  return undefined;
}

// Check 4: Parse and return the entire object
const parsedCookie = JSON.parse(decodedCookie);
return parsedCookie;


___WEB_PERMISSIONS___

[
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
        "publicId": "get_cookies",
        "versionId": "1"
      },
      "param": [
        {
          "key": "cookieAccess",
          "value": {
            "type": 1,
            "string": "any"
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
- name: Returns undefined if cookie is missing
  code: |-
    const mockData = {
      cookieName: "SwitchTempData"
    };

    // Mock the cookie API to return an empty array (simulating no cookie)
    mock('getCookieValues', function() {
      return [];
    });

    let variableResult = runCode(mockData);

    // Verify the variable gracefully returns undefined
    assertThat(variableResult).isEqualTo(undefined);
- name: Parses and returns valid session data object
  code: |-
    const mockData = {
      cookieName: "SwitchTempData"
    };

    // Mock the cookie API to return a base64 encoded JSON string
    // The string below is the base64 equivalent of: {"email":"test@test.com","customer_first_name":"John"}
    mock('getCookieValues', function() {
      return ["eyJlbWFpbCI6InRlc3RAdGVzdC5jb20iLCJjdXN0b21lcl9maXJzdF9uYW1lIjoiSm9obiJ9"];
    });

    let variableResult = runCode(mockData);

    // Verify the variable returns the fully parsed object
    assertThat(variableResult.email).isEqualTo("test@test.com");
    assertThat(variableResult.customer_first_name).isEqualTo("John");


___NOTES___

Created on 5/13/2026, 8:04:00 PM


