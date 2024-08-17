library sitemap;

import 'package:intl/intl.dart';
import 'package:xml/xml.dart';

/// Represents an entire Sitemap file.
class Sitemap {
  String? stylesheetPath;

  List<SitemapEntry> entries = [];

  String generate() {
    final dateFormatter = DateFormat('yyyy-MM-dd');

    final root = XmlElement(XmlName('urlset'), [XmlAttribute(XmlName('xmlns'), 'http://www.sitemaps.org/schemas/sitemap/0.9'), XmlAttribute(XmlName('xmlns:xhtml'), 'http://www.w3.org/1999/xhtml')]);

    for (final entry in entries) {
      final url = XmlElement(XmlName('url'));

      final location = XmlElement(XmlName('loc'));
      location.children.add(XmlText(entry.location));
      url.children.add(location);

      url.children.addAll(entry.alternates
          .map<String, XmlNode>((String language, String location) => MapEntry<String, XmlNode>(
              language, XmlElement(XmlName('xhtml:link'), [XmlAttribute(XmlName('rel'), 'alternate'), XmlAttribute(XmlName('hreflang'), language), XmlAttribute(XmlName('href'), location)])))
          .values);

      final lastMod = XmlElement(XmlName('lastmod'));
      lastMod.children.add(XmlText(dateFormatter.format(entry.lastModified)));
      url.children.add(lastMod);

      final changeFrequency = XmlElement(XmlName('changefreq'));
      changeFrequency.children.add(XmlText(entry.changeFrequency));
      url.children.add(changeFrequency);

      final priority = XmlElement(XmlName('priority'));
      priority.children.add(XmlText(entry.priority.toString()));
      url.children.add(priority);

      root.children.add(url);
    }

    String stylesheet = '';
    if (stylesheetPath != null) {
      stylesheet = '<?xml-stylesheet type="text/xsl" href="$stylesheetPath"?>';
    }

    return '<?xml version="1.0" encoding="UTF-8"?>$stylesheet$root';
  }
}

/// Represents a single Sitemap entry.
class SitemapEntry {
  String location = '';
  DateTime lastModified = DateTime.now();
  final String changeFrequency;
  final num priority;
  final Map<String, String> _alternates = {};
  Map<String, String> get alternates => _alternates;
  void addAlternate(String language, String location) => _alternates[language] = location;

  SitemapEntry({
    this.changeFrequency = 'monthly',
    this.priority = 0.5,
  });
}
