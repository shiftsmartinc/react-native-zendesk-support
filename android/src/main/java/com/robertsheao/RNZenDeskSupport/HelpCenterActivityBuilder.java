package com.robertsheao.RNZenDeskSupport;

import android.os.Bundle;

import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import zendesk.commonui.UiConfig;
import zendesk.core.*;
import com.zendesk.util.*;
import com.zendesk.logger.*;

import zendesk.support.RequestProvider;
import zendesk.support.Support;
import zendesk.support.request.RequestActivity;
import zendesk.support.guide.HelpCenterActivity;
import zendesk.support.guide.*;
import zendesk.support.guide.HelpCenterUiConfig;
import zendesk.support.guide.HelpCenterUiConfig.Builder;

import java.io.Serializable;
import java.util.ArrayList;

/**
 * Created by Patrick O'Connor on 11/8/17.
 * This is a mostly a copy of Zendesk's SupportActivity.Builder.class, modified slightly to allow configuration from the React Native module.
 * It also adds the Intent.FLAG_ACTIVITY_NEW_TASK flag to the created Intent, fixing a crashing bug in older versions of Android.
 * https://github.com/RobertSheaO/react-native-zendesk-support
 */

class HelpCenterActivityBuilder extends HelpCenterUiConfig.Builder {
  private final Bundle args = new Bundle();


  private static long[] toLongArray(ArrayList<?> values) {
    long[] arr = new long[values.size()];
    for (int i = 0; i < values.size(); i++)
      arr[i] = Long.parseLong((String) values.get(i));
    return arr;
  }

  public HelpCenterActivityBuilder() {
    super();
    this.withShowConversationsMenuButton(true);
    this.withContactUsButtonVisible(true);
  }

  HelpCenterActivityBuilder withOptions(ReadableMap options) {
    if (!(options == null || options.toHashMap().isEmpty())) {
      if (options.hasKey("showConversationsMenuButton")) {
        this.showConversationsMenuButton(options.getBoolean("showConversationsMenuButton"));
      }
      if (options.hasKey("articleVotingEnabled")) {
        this.withArticleVoting(options.getBoolean("articleVotingEnabled"));
      }
      if (options.hasKey("withContactUsButtonVisibility")) {
        switch(options.getString("withContactUsButtonVisibility")) {
          case "OFF":
            withContactUsButtonVisibility(false);
            break;
          case "ARTICLE_LIST_ONLY":
            withContactUsButtonVisibility(true);
            break;
          case "ARTICLE_LIST_AND_ARTICLE":
          default:
            withContactUsButtonVisibility(true);
        }
      }
    }
    return this;
  }

  HelpCenterActivityBuilder withArticlesForCategoryIds(ReadableArray categoryIds) {
    return withArticlesForCategoryIds(toLongArray(categoryIds.toArrayList()));
  }

  private HelpCenterActivityBuilder withArticlesForCategoryIds(long... categoryIds) {
    if(this.args.getLongArray("extra_section_ids") != null) {
      Logger.w("SupportActivity", "Builder: sections have already been specified. Removing section IDs to set category IDs.", new Object[0]);
      this.args.remove("extra_section_ids");
    }

    this.args.putLongArray("extra_category_ids", categoryIds);
    return this;
  }

  HelpCenterActivityBuilder withArticlesForSectionIds(ReadableArray sectionIds) {
    return withArticlesForSectionIds(toLongArray(sectionIds.toArrayList()));
  }

  private HelpCenterActivityBuilder withArticlesForSectionIds(long... sectionIds) {
    if(this.args.getLongArray("extra_category_ids") != null) {
      Logger.w("SupportActivity", "Builder: categories have already been specified. Removing category IDs to set section IDs.", new Object[0]);
      this.args.remove("extra_category_ids");
    }

    this.args.putLongArray("extra_section_ids", sectionIds);
    return this;
  }

  private HelpCenterActivityBuilder  withContactUsButtonVisibility(boolean contactUsButtonVisibility) {
    this.args.putSerializable("extra_contact_us_button_visibility", contactUsButtonVisibility);
    return this;
  }

  private HelpCenterActivityBuilder withContactConfiguration(UiConfig  configuration) {
    if(configuration != null) {
      configuration = (UiConfig)configuration;
    }

    this.args.putSerializable("extra_contact_configuration", (Serializable)configuration);
    return this;
  }

  //noinspection SuspiciousToArrayCall
  HelpCenterActivityBuilder withLabelNames(ReadableArray labelNames) {
    return withLabelNames(labelNames.toArrayList().toArray(new String[]{}));
  }

  public HelpCenterActivityBuilder withLabelNames(String... labelNames) {
    if(CollectionUtils.isNotEmpty(labelNames)) {
      this.args.putStringArray("extra_label_names", labelNames);
    }

    return this;
  }

  public HelpCenterActivityBuilder withCategoriesCollapsed(boolean categoriesCollapsed) {
    this.args.putBoolean("extra_categories_collapsed", categoriesCollapsed);
    return this;
  }

  public HelpCenterActivityBuilder showConversationsMenuButton(boolean showConversationsMenuButton) {
    this.args.putBoolean("extra_show_conversations_menu_button", showConversationsMenuButton);
    return this;
  }

  private HelpCenterActivityBuilder withArticleVoting(boolean articleVotingEnabled) {
    this.args.putBoolean("article_voting_enabled", articleVotingEnabled);
    return this;
  }

}
