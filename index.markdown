---
title: AMON Data Format
layout: default
---

# AMON v2.0

## <a name="copyright"></a>Copyright

Copyright (c) 2010-2011 AMEE UK Limited.

<http://amee.github.com/AMON>

## <a name="abstract"></a>Abstract

AMON is a data format suitable for the description and exchange of metering/monitoring device data. AMON is available to be used, free of charge, by anyone who has a need to describe or exchange, in a computer readable format, metering or monitoring device data.

The AMON standard has been primarily developed by [AMEE UK Limited](http://www.amee.com/) with the assistance of a number of other parties in the metering/monitoring device industry. If you would like to participate in the further development of the AMON standard, please see the [Contributing to AMON](#contribute) section.

AMEE has developed a storage platform for metering/monitoring device data and a RESTful, web-based API for storing and retrieving this data using the AMON data format. However, the use of AMON is not limited to this context, and a key aim of the AMON data format is to advocate an open way of describing and exchanging metering/monitoring data that is independent of any API or system. The use of AMON in metering/monitoring devices and/or other systems is encouraged.

## <a name="license"></a>License

The AMON standard is licensed under a [Creative Commons Attribution 2.0 UK: England & Wales License](http://creativecommons.org/licenses/by/2.0/uk/). 

## <a name="toc"></a>Table of Contents

* [Copyright](#copyright)
* [Abstract](#abstract)
* [License](#license)
* [Table of Contents](#toc)
* [Goals of AMON](#goals)
* [The AMON Data Format](#data_format)
  * [Data Format Description](#description)
  * [UUIDs](#UUIDs)
  * [Numbers](#numbers)
  * [Meters](#meters)
  * [Metering Points](#metering_points)
  * [Entities](#entities)
  * [Standard Reading Types](#reading_types)
* [Examples](#examples)
* [References](#references)
* [Appendix](#appendix)
  * [Revision History](#history)
  * [Contributing to AMON](#contribute)
  * [Contributors](#contributors)

## <a name="goals"></a>Goals of AMON

The AMON data format has been developed with the following goals in mind:

* To be suitable for the description and exchange of metering/monitoring device data;
* To be human readable and self-documenting;
* To be able to be widely supported;
* To be bandwidth sensitive;
* To be simple; and 
* To be extensible, easily supporting new data types.

To this end:

* The data format defines a number of commonly used data fields for devices (such as the device name, its location etc.), and a number of commonly used data fields for device readings. This ensures that the data format is suitable for the description and exchange of metering/monitoring device data and is simple to use. 
* The data format uses JSON encoding [\[1\]](#1). This ensures that the data format balances the need to be human readable and self-documenting against the need to be bandwidth sensitive. Additionally, as most languages have library support for JSON encoding, AMON is able to be widely supported.
* Finally, although the data format does define commonly used data fields for devices and device readings, it does not exclude the use of custom device data or reading data. These can be described and exchanged using the AMON data format without modification to the data format, ensuring that the format is extensible.

## <a name="data_format"></a>The AMON Data Format

The the full AMON data format is shown below. A [full description of the format](#description) follows, along with [examples](#examples) of realistic AMON formatted data.

    {

      "meters": [
        {
          "meterId": required string UUID,
          "description": optional string,
          "originId": optional string UUID,
          "meteringPointId": optional string UUID,
          "privacy": required string, either "private" or "public",
          "location": {
            "name": optional string,
            "latitude": optional latitude in degrees,
            "longitude": optional longitude in degrees
          },
          "metadata": {
            optional JSON object
          },      
          "readings": [
            {
              "type": required string,
              "unit": optional string,
              "resolution": optional number,
              "accuracy": optional number,
              "period": required string, currently only "instant" supported
            },
          ],
          "measurements": [
            {
              "type": required string,
              "timestamp": RFC 3339 string, required,
              "value": number, boolean or string, required unless "error" (below) is present,
              "error": string, required unless "value" (above) is present,
              "aggregated": optional boolean
            },
          ]    
        }
      ],

      "meteringPoints": [
        {
          "meteringPointId": required string UUID,
          "description": optional string,
          "metadata": {
            optional JSON object
          }
        }    
      ],

      "entities": [
        {
          "entityId": required string UUID,
          "description": optional string,
          "meterIds": [ required array of string UUIDs, empty array permitted ],
          "meteringPointIds": [ optional array of string UUIDs, empty array permitted ]
        }
      ]

    }

### <a name="description"></a>Data Format Description

The AMON data format describes metering/monitoring devices, their data, and their relationship with other entities in a JSON encoded [\[1\]](#1) string with structure as shown above.

The AMON data format consists of three main sections:

* **meters**: The "meters" section is used for representing physical or virtual metering/monitoring devices and their data;
* **meteringPoints**: The "meteringPoints" section is used for representing physical or virtual *metering points* -- that is, physical or virtual points where metering/monitoring is performed (perhaps for billing purposes) but which is desired to be kept separate from a physical or virtual metering/monitoring devices (e.g. so that if a device fails, and needs to be replaced, the "meteringPoint" can remain, and a new "meter" can be added to replace the old "meter"); or a physical or virtual collection of metering/monitoring devices with a related purpose (e.g. an electrical metering system as a "meteringPoint" with a number of sub-"meters").
* **entities**: The "entities" section is used for representing real world or virtual *entities* that may relate to "meters" and/or "meteringPoints", such as businesses, properties, buildings, people, universities -- anything, really, that may have a 1:n relationship with "meters" and/or "meteringPoints".

### <a name="UUIDs"></a>UUIDs

Where a string UUID is defined in the data format, a standard Universally Unique Identifier [\[3\]](#3) should be used.

### <a name="numbers"></a>Numbers

Where a number is defined in the data format, positive and negative integers and floating point numbers are acceptable. Numbers may be defined in either normal numeric or scientific notation. (It is left up to the implementation of devices/systems that use AMON regarding the precision of floating point numbers.)

### <a name="meters"></a>Meters

In the AMON data format, the "meters" section is used to represent physical or virtual metering/monitoring devices and their data. This is done via three sub-sections. Firstly, a series of fields that define details about the physical or virtual device itself, such as a UUID for the "meter", if the device's data should be considered to be public or private, the location of the device, and optional metadata about the device. Secondly, a series of fields (the "readings" section) which defines *what* the device records measurements of -- so, for example, if a device monitors temperature and relative humidity, then the "readings" section would define this. Finally, a series of fields (the "measurements" section) which defines actual metering/monitoring data from the device.

The AMON data format also allows for a "meter" to be a *clone* clone of another "meter". This allows the AMON data format to handle cases where (for example) it is desirable to describe or exchange raw data collected from a meter/monitor separately from the description/exchange of "corrected" data from that same meter/monitor (e.g. data where data outliers may have been removed, and/or correction factors and/or smoothing applied to the data, etc.).

All of the fields for the "meters" section of the AMON data format are discussed in more detail below.

* **meterId**: A UUID for the "meter". Required for a "meter"; however, systems that implement the AMON data format may relax this requirement to make the field optional for AMON formatted messages that are requesting that a "meter" be created. 
* **description**: An optional textual description of the meter. Commonly used for an in-house meter ID and/or other useful identifier.
* **originId**: An optional UUID of another "meter", if this "meter" is a clone of that "meter".
* **meteringPointId**: An optional UUID of a "meteringPoint", if this "meter" is to be considered part of that "meteringPoint".
* **privacy**: Should the information about this meter/monitor and its data be considered private, or public? Optional -- systems that implement the AMON data format should assume a default of "private" if not specified.
* **location**: 
  * **name**: Optional textual description of the location of the "meter".
  * **latitude**: Optional latitude of the "meter".
  * **longitude**: Optional longitude of the "meter".
* **metadata**: An optional JSON object of metadata about the "meter". This allows the AMON data format to handle any type of metadata relating to the "meter".
* **readings**: The "readings" section defines what type of readings the "meter" validly produces. An array of zero or more sets of values.
  * **type**: A required string, defining a name for the type of "reading". A set of [standard reading types](#reading_types) is listed below; however, the AMON data format does not specify any requirement regarding reading types. While it is recommended that the standard reading types be used, users of the data format are free to define and use their own type definitions, as appropriate to their devices and data.
  * **unit**: Optional string, defining the unit for the "reading". Units must be a valid unit as defined by the JScience library. [\[3\]](#3) [\[4\]](#4)
  * **resolution**: Optional string, defining the resolution of the "reading".
  * **accuracy**: Optional string, defining the accuracy of the "reading".
  * **period**: Required string, defining the type of "reading". Currently, only "instant" is supported. Readings of type "instant" are readings are from devices that, at a given instant in time, produce a "measurement" (e.g. current temperature, current relative humidity, current number of gas units used, etc.). Other types may be added in the future. Systems that implement the AMON data format should assume a default of "instant" if not supplied.
* **measurements**: The "measurements" section defines actual data measurements from the "meter". An array of zero or more sets of values.
  * **type**: A required string, referencing a "reading" type that is defined for the "meter". All data measurements supplied for a "meter" *must* use a "reading" "type" that has been defined for the "meter".
  * **timestamp**: RFC 3339 [\[2\]](#2) string, required. The date/time that the "measurement" was produced.
  * **value**: Optional number, boolean or string, being the actual "measurement" value.
  * **error**: Optional string, describing an error condition if no "value" is present.
  * **aggregated**: Optional boolean, set to true if the measurement data being described/exchanged has been aggregated (i.e. is not individual raw data values, but has been aggregated to reduce the number of "measurement" items that need to be listed).

### <a name="metering_points"></a>Metering Points

In the AMON data format, the "meteringPoints" section is used to represent physical or virtual metering points. Note that because the relationship between a "meter" and a "meteringPoint" is defined in the "meter" section of the data format, a "meteringPoint" may have one or more "meters"; but a "meter" may belong to at most one "meteringPoint".

All of the fields for the "meteringPoints" section of the AMON data format are discussed in more detail below.

* **meteringPointId**: A UUID for the "meteringPoint". Required for a "meteringPoint"; however, systems that implement the AMON data format may relax this requirement to make the field optional for AMON formatted messages that are requesting that a "meteringPoint" be created.
* **description**: An optional textual description of the metering point.
* **metadata**: An optional JSON object of metadata about the "meteringPoint". This allows the AMON data format to handle any type of metadata relating to the "meter".

### <a name="entities"></a>Entities

In the AMON data format, the "entities" section is used to represent physical or virtual entities which may have a relationship with a "meter" or "meteringPoint".

All of the fields for the "entities" section of the AMON data format are discussed in more detail below.

* **entityId**: A UUID for the "entity". Required for an "entity"; however, systems that implement the AMON data format may relax this requirement to make the field optional for AMON formatted messages that are requesting than an "entity" be created. 
* **description**: An optional textual description of the entity.
* **meterIds**: An array of "meter" UUIDs, representing the "meters" that belong to the "entity".
* **meteringPointIds**: An array of "meteringPoint" UUIDs, representing the "meteringPoints" that belong to the "entity".

### <a name="reading_types"></a>Standard Reading Types

All "meters" in the AMON data format must, in order to be able to describe/exchange metering/monitoring data, define "readings", to which "measurements" can then be associated via the defined "type".

As mentioned above, the AMON data format does not specify any requirement regarding what "reading" "types" must be. However, the following table represents "types" that are commonly used in the metering/monitoring field. If a "type" exists in the following table, it is recommended that this be used when using the data format, as this will improve the ability to interchange AMON formatted data between different systems.

Each of the standard "types" below is listed with a proposed default "reading" "unit", which systems implementing AMON should use in the event that no unit is defined in a "meter" "reading" section for that "type".

<table>
  <thead>
    <tr><th>Type Name</th><th>Default Unit</th><th>JSON Type</th></tr>
  </thead>
  <tbody>
    <tr>  <td>electricalInput</td>         <td>kWh</td>      <td>Number</td>   </tr>
    <tr>  <td>electricalOutput</td>        <td>kWh</td>      <td>Number</td>   </tr>
    <tr>  <td>electricityConsumption</td>  <td>kWh</td>      <td>Number</td>   </tr>
    <tr>  <td>electricityExport</td>       <td>kWh</td>      <td>Number</td>   </tr>
    <tr>  <td>gasAsHeatingFuel</td>        <td>m^3</td>      <td>Number</td>   </tr>
    <tr>  <td>heatOutput</td>              <td>kWh</td>      <td>Number</td>   </tr>
    <tr>  <td>humidity</td>                <td>gm^-3</td>    <td>Number</td>   </tr>
    <tr>  <td>solarRadiation</td>          <td>wm^-2</td>    <td>Number</td>   </tr>
    <tr>  <td>temperature</td>             <td>C</td>        <td>Number</td>   </tr>
    <tr>  <td>waterConsumption</td>        <td>L</td>        <td>Number</td>   </tr>
    <tr>  <td>windDirection</td>           <td>degrees</td>  <td>Number</td>   </tr>
    <tr>  <td>windSpeed</td>               <td>ms^-1</td>    <td>Number</td>   </tr>
    <tr>  <td>windowOpen</td>              <td></td>         <td>Boolean</td>  </tr>
  </tbody>
</table>

##  <a name="examples"></a>Data Examples
  
### Example 1 - Temperature readings

This example shows a "meter", with UUID "d46ec860-fc7d-012c-25a6-0017f2cd3574". 

The "meter" has a "location", and has been defined with one "reading". 

Two "measurements" for the defined "reading" exist.

    {
      "meters": [
        {
          "meterId": "d46ec860-fc7d-012c-25a6-0017f2cd3574",
          "location": {
            "name": "kitchen"
          },
          "readings": [
            {
              "type": "temperature",
              "unit": "C",
              "accuracy": 0.01
            }
          ],
          "measurements": [
            {
              "type": "temperature",
              "timestamp": "2010-07-02T11:39:09Z",
              "value": 23.5
            },
            {
              "type": "temperature",
              "timestamp": "2010-07-02T11:44:09Z",
              "value": 23.8
            }
          ]
        }
      ]
    }

### Example 2 - Electricity readings with associated metering point

This example shows a "meter", with UUID "c1810810-0381-012d-25a8-0017f2cd3574", as well as a "meteringPoint" with UUID "c1759810-90f3-012e-0404-34159e211070".

The "meter" belongs to the "meteringPoint", and has been defined with two "readings". 

One "measurements" for each of the defined "readings" exist.

    {
      "meters": [
        {
          "meterId": "c1810810-0381-012d-25a8-0017f2cd3574",
          "meteringPointId": "c1759810-90f3-012e-0404-34159e211070",
          "readings": [
            {
              "type": "apparentPower",
              "unit": "kVAh",
              "accuracy": 0.01
            },
            {
              "type": "reactivePower",
              "unit": "kVArh",
              "accuracy": 0.2
            }
          ],
          "measurements": [
            {
              "type": "apparentPower",
              "timestamp": "2010-07-02T11:39:09Z",
              "value": 7.23
            },
            {
              "type": "reactivePower",
              "timestamp": "2010-07-02T11:44:09Z",
              "value": 6.8
            }
          ]
        }
      ],
      "meteringPoints": [
        {
          "meteringPointId": "c1759810-90f3-012e-0404-34159e211070",
        }
      ]
    }

### Example 3 - Wind turbine measurements

This example shows two "meters", the first with UUID "82621440-fc7f-012c-25a6-0017f2cd3574" and the second with UUID "d1635430-0381-012d-25a8-0017f2cd3574".

The first "meter" has been defined with three different "readings", and one "measurements" for each of the defined "readings" exist.

The second "meter" has been defined with one "reading", and one "measurements" for that "readings" exists.

    {
      "meters": [
        {
          "meterId": "82621440-fc7f-012c-25a6-0017f2cd3574",
          "readings": [
            {
              "type": "electricalInput"
            },
            {
              "type": "electricalOutput"
            },
            {
              "type": "electricalExport"
            }
          ],
          "measurements": [
            {
              "type": "electricalInput",
              "timestamp": "2010-07-02T11:39:09Z",
              "value": 0.6
            },
            {
              "type": "electricalOutput",
              "timestamp": "2010-07-02T11:39:09Z",
              "value": 4.5
            },
            {
              "type": "electricalExport",
              "timestamp": "2010-07-02T11:39:09Z",
              "value": 3.9
            }
          ]
        },
        {
          "meterId": "d1635430-0381-012d-25a8-0017f2cd3574",
          "readings": [
            {
              "type": "windDirection"
            }
          ],
          "measurements": [
            {
              "type": "windDirection",
              "timestamp": "2010-07-02T11:39:09Z",
              "value": 243
            }
          ]
        }
      ]
    }

### Example 4 - Associating meters and metering points with an entity

This example shows an "entity", with UUID "0636240-0381-012d-25a8-0017f2cd3574". 

The entity is defined as being associated with two "meters", those with UUIDs "c1810810-0381-012d-25a8-0017f2cd3574" and "d46ec860-fc7d-012c-25a6-0017f2cd3574", and also with one "meteringPoint", with UUID "c1759810-90f3-012e-0404-34159e211070".

    {
      "entities": [
        {
          "entityId": "90636240-0381-012d-25a8-0017f2cd3574",
          "meterIds": [
            "c1810810-0381-012d-25a8-0017f2cd3574",
            "d46ec860-fc7d-012c-25a6-0017f2cd3574"
          ],
          "meteringPointIds": [
            "c1759810-90f3-012e-0404-34159e211070"
          ]
        }
      ]
    }

### Example 5 - Non-numeric measurements

This example shows a "meter", with UUID "ed221bf0-d075-012d-287e-0017f2cd3574".

The "meter" has been defined with one "reading", and two "measurements" for that "readings" exists. Note, however, that the "value" of the "measurements" in this case are boolean values.

    {
      "meters": [
        {
          "meterId": "ed221bf0-d075-012d-287e-0017f2cd3574",
          "readings": [
            {
              "type": "windowOpen"
            }
          ],
          "measurements": [
            {
              "type": "windowOpen",
              "timestamp": "2010-11-12T13:51:43Z",
              "value": true
            },
            {
              "type": "windowOpen",
              "timestamp": "2010-11-12T17:51:53Z",
              "value": false
            }
          ]
        }
      ]
    }

## <a name="references"></a>References

1. <http://json.org/> <a name="1"></a>
2. <http://www.ietf.org/rfc/rfc3339.txt> <a name="2"></a>
3. <http://en.wikipedia.org/wiki/Universally_Unique_Identifier> <a name="3"></a>
4. <http://jscience.org/api/javax/measure/unit/SI.html> <a name="4"></a>
5. <http://jscience.org/api/javax/measure/unit/NonSI.html> <a name="5"></a>

## <a name="appendix"></a>Appendix

### <a name="history"></a>Revision History

* Version 2.0: 2011-09-12 - Andrew Hill
  * <https://github.com/AMEE/AMON/issues/1>: Added the "description" field to "meters", "meteringPoints" and "entities".
  * <https://github.com/AMEE/AMON/issues/2>: Removed the "duration" reading type, as feedback suggested that this type is not relevant at all to metering/monitoring device manufacturers -- readings are always taken at an instant in time with only a single timestamp available for the reading.
  * Made a minor typo correcton to the revision history log.
* Version 0.9: 2011-08-15 - Andrew Hill
  * Major update to the description of the AMON data format.
  * Major update to the layout of the document.
  * Removed text relating to AMEE's implementation of AMON that are not relevant to the data format.
  * Updated the specification for "meteringPoints" to allow them to be more general; "meteringPoints" are no longer confined to representing customer billing points.
* Version 0.8: 2011-05-12 - Andrew Hill
  * Further clarification made between the AMON standard and the API.
  * Minor improvements to documentation of data format.
* Version 0.7: 2010-11-26 - Paul Carey
  * Clarified relationship between the AMON standard and API.
  * Removed redundant reference to name in reading.
* Version 05 - 0.6: 2010-11-12 - Paul Carey
  * Added string and boolean to measurement value types.
  * Removed now redundant Reserved Property Names.
  * Added Contributors section.
  * Added windowOpen type.
* Version 0.4: 2010-08-16 - Paul Carey
  * Added location and error fields.
  * Formalised separation between format and API.
* Version 0.1 - 0.3: 2010-07-02 - Paul Carey
  * Updated to reflect current usage and demands.
  * Modified based on itial feedback
  * Initial version created.

### <a name="contribute"></a>Contributing to AMON

Contributions to the AMON data format are welcome! If you would like to participate in the development of the AMON data format, please see the following:

* [AMON Data Format](http://amee.github.com/AMON)
* [AMON Discussion Forum](http://groups.google.com/group/amon_data_format)
* [AMON Issue Tracker](https://github.com/AMEE/AMON/issues)

### <a name="contributors"></a>Contributors

* Diggory Briercliffe
* Paul Carey <paul.p.carey@gmail.com>
* Bo Fussing
* Andrew Hill <andrew.hill@amee.com>
* David Keen <david.keen@amee.com>
* Jon Leighton
* John Nunn
