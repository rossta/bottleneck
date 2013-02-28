App.ProjectsView = Ember.View.extend({
  templateName: "projects/projects"
});

App.ProjectView = Ember.View.extend({
  templateName: "projects/project"
});

App.ProjectSummaryView = Ember.View.extend({
  templateName: "projects/summary"
});

App.ProjectFlowView = Ember.View.extend({
  templateName: "projects/flow"
});

App.ProjectOutputView = Ember.View.extend({
  templateName: "projects/output"
});

App.ProjectBreakdownView = Ember.View.extend({
  templateName: "projects/breakdown"
});

App.ProjectSettingsView = Ember.View.extend({
  templateName: "projects/settings"
});

App.ProjectNavView = Ember.View.extend({
  templateName: "projects/nav"
});

App.ProjectNavItemView = Ember.View.extend({
  tagName: 'dd'
});
